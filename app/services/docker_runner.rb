# app/services/docker_runner.rb
require 'tempfile'
require 'securerandom'

class DockerRunner
  TIMEOUT = 10
  MEMORY_LIMIT = "128m"

  LANGUAGES = {
    "ruby" =>   { image: "ruby:3.3-alpine",   extension: ".rb",  command: "ruby" },
    "python" => { image: "python:3.11-alpine", extension: ".py", command: "python" },
    "java" =>   { image: "openjdk:17-alpine", extension: ".java", command: nil, requires_compile: true }
  }.freeze

  class << self
    # Now accepts optional image/extension/command for custom languages
    def run(language, code, image: nil, extension: nil, command: nil)
      # Use provided or default config
      config = LANGUAGES[language]&.dup || {}

      config[:image]     = image     || config[:image]
      config[:extension] = extension || config[:extension]
      config[:command]   = command   || config[:command]

      unless config[:image] && config[:extension] && config[:command]
        return { success: false, output: "Error: Missing configuration for #{language}" }
      end

      # Pull image if needed
      ensure_image_exists(config[:image])

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
        `docker pull #{image} 2>&1`
      end
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
      {
        success: false,
        output: "Java execution coming soon! (Requires compilation step)"
      }
    end

    def execute_with_timeout(command, timeout)
      require 'timeout'
      require 'open3'

      output = ""
      error = ""

      Timeout.timeout(timeout) do
        output, error, status = Open3.capture3(command)
        combined = "#{error}#{output}".strip
        combined.empty? ? "(No output)" : combined
      end
    end
  end
end
