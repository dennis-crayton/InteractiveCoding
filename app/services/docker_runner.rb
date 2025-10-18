# app/services/docker_runner.rb
require 'tempfile'
require 'securerandom'

class DockerRunner
  # Maximum execution time in seconds
  TIMEOUT = 10
  
  # Maximum memory limit
  MEMORY_LIMIT = "128m"
  
  # Language configurations
  LANGUAGES = {
    "ruby" => {
      image: "ruby:3.3-alpine",
      extension: ".rb",
      command: "ruby"
    },
    "python" => {
      image: "python:3.11-alpine",
      extension: ".py",
      command: "python"
    },
    "java" => {
      image: "openjdk:17-alpine",
      extension: ".java",
      command: nil,  # Java requires compilation
      requires_compile: true
    }
  }.freeze
  
  class << self
    def run(language, code)
      # Validate language
      unless LANGUAGES.key?(language)
        return { success: false, output: "Error: Unsupported language '#{language}'" }
      end
      
      config = LANGUAGES[language]
      
      # Pull image if not present (do this once)
      ensure_image_exists(config[:image])
      
      # Execute code based on language
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
      # Check if image exists locally
      result = `docker images -q #{image} 2>/dev/null`.strip
      
      if result.empty?
        Rails.logger.info "Pulling Docker image: #{image}"
        `docker pull #{image} 2>&1`
      end
    end
    
    def run_with_file(config, code)
      # Create a temporary file with the code
      temp_file = Tempfile.new(['code', config[:extension]])
      
      begin
        # Write code to temp file
        temp_file.write(code)
        temp_file.flush
        temp_file.close
        
        # Get the temp file path
        host_path = temp_file.path
        container_path = "/tmp/code#{config[:extension]}"
        
        # Build docker command with volume mount
        docker_cmd = [
          "docker run",
          "--rm",                                    # Remove container after execution
          "--network none",                          # No network access
          "--memory=#{MEMORY_LIMIT}",               # Memory limit
          "--cpus=0.5",                             # CPU limit
          "--pids-limit=50",                        # Process limit
          "-v #{host_path}:#{container_path}:ro",   # Mount code file (read-only)
          config[:image],
          config[:command],
          container_path
        ].join(" ")
        
        # Execute with timeout
        output = execute_with_timeout(docker_cmd, TIMEOUT)
        
        { success: true, output: output }
      ensure
        # Clean up temp file
        temp_file.unlink if temp_file
      end
    rescue Timeout::Error
      { success: false, output: "Error: Code execution timed out (#{TIMEOUT}s limit)" }
    rescue => e
      { success: false, output: "Error: #{e.message}" }
    end
    
    def run_java(code)
      # Java requires compilation, more complex setup
      # We'll implement this later
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
        
        # Combine stdout and stderr, prioritizing stderr for errors
        combined = ""
        combined += error unless error.empty?
        combined += output unless output.empty?
        
        if combined.empty?
          "(No output)"
        else
          combined.strip
        end
      end
    end
  end
end