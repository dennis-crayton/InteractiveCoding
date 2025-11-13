# app/services/docker_runner.rb
require 'tempfile'
require 'securerandom'
require 'fileutils'

class DockerRunner
  TIMEOUT = 10
  MEMORY_LIMIT = "128m"

  LANGUAGES = {
    "ruby" =>   { image: "ruby:3.3-alpine",   extension: ".rb",  command: "ruby" },
    "python" => { image: "python:3.11-alpine", extension: ".py", command: "python" },
    "java" =>   { image: "eclipse-temurin:17-jdk", extension: ".java", command: nil, requires_compile: true }
  }.freeze

  class << self
    def run(language, code, image: nil, extension: nil, command: nil)
      config = LANGUAGES[language]&.dup || {}

      config[:image]     = image     || config[:image]
      config[:extension] = extension || config[:extension]
      config[:command]   = command   || config[:command]

      if !LANGUAGES[language] && (!config[:image] || !config[:extension] || !config[:command])
        return { success: false, output: "Error: Missing configuration for custom language '#{language}'" }
      end

      if LANGUAGES[language] && language != "java" && !config[:command]
        return { success: false, output: "Error: Missing command for language '#{language}'" }
      end

      unless ensure_image_exists(config[:image])
        return { success: false, output: "Error: Failed to pull or find Docker image '#{config[:image]}'" }
      end

      if language == "java"
        run_java(code)
      else
        run_with_file(config, code)
      end
    rescue => e
      Rails.logger.error "Docker execution error: #{e.message}\n#{e.backtrace.join("\n")}"
      { success: false, output: "Error: #{e.message}" }
    end

    private

    def ensure_image_exists(image)
      result = `docker images -q #{image} 2>/dev/null`.strip
      if result.empty?
        Rails.logger.info "Pulling Docker image: #{image}"
        pull_output = `docker pull #{image} 2>&1`
        Rails.logger.info pull_output
        result = `docker images -q #{image} 2>/dev/null`.strip
      end
      !result.empty?
    end

    def run_with_file(config, code)
      temp_file = Tempfile.new(['code', config[:extension]])
      begin
        temp_file.write(code)
        temp_file.flush
        temp_file.close

        host_path = temp_file.path
        container_path = "/tmp/code#{config[:extension]}"

        docker_cmd = [
          "docker run",
          "--rm",
          "--network none",
          "--memory=#{MEMORY_LIMIT}",
          "--cpus=0.5",
          "--pids-limit=50",
          "-v #{host_path}:#{container_path}:ro",
          config[:image],
          config[:command],
          container_path
        ].join(" ")

        output = execute_with_timeout(docker_cmd, TIMEOUT)
        { success: true, output: output }
      ensure
        temp_file.unlink if temp_file
      end
    rescue Timeout::Error
      { success: false, output: "Error: Code execution timed out (#{TIMEOUT}s limit)" }
    rescue => e
      { success: false, output: "Error: #{e.message}" }
    end

    def run_java(code)
      class_name = extract_java_class_name(code)

      unless class_name
        return {
          success: false,
          output: "Error: Could not find a public class in your Java code.\nMake sure you have 'public class ClassName' in your code."
        }
      end

      temp_dir = Dir.mktmpdir

      begin
        java_file = File.join(temp_dir, "#{class_name}.java")
        File.write(java_file, code)

        Rails.logger.info "Java temp dir: #{temp_dir}"
        Rails.logger.info "Java class name: #{class_name}"

        docker_cmd = [
          "docker run",
          "--rm",
          "--network none",
          "--memory=256m",
          "--cpus=1.0",
          "--pids-limit=50",
          "-v #{temp_dir}:/app",
          "-w /app",
          "eclipse-temurin:17-jdk",
          "bash", "-c",
          "javac #{class_name}.java && java #{class_name}"
        ].join(" ")

        Rails.logger.info "Java docker command: #{docker_cmd}"

        output = execute_with_timeout(docker_cmd, TIMEOUT * 2)
        { success: true, output: output }
      ensure
        FileUtils.remove_entry(temp_dir) if temp_dir && File.exist?(temp_dir)
      end
    rescue Timeout::Error
      {
        success: false,
        output: "Error: Code execution timed out (#{TIMEOUT * 2}s limit for Java compilation)"
      }
    rescue => e
      Rails.logger.error "Java execution error: #{e.message}\n#{e.backtrace.join("\n")}"
      { success: false, output: "Error: #{e.message}" }
    end

    def extract_java_class_name(code)
      match = code.match(/public\s+class\s+(\w+)/)
      match ? match[1] : nil
    end

    def execute_with_timeout(command, timeout)
      require 'timeout'
      require 'open3'

      Timeout.timeout(timeout) do
        output, error, status = Open3.capture3(command)
        combined = "#{error}#{output}".strip
        combined.empty? ? "(No output)" : combined
      end
    end
  end
end
