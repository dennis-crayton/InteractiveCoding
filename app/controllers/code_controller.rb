# app/controllers/code_controller.rb
class CodeController < ApplicationController
  # Disable CSRF protection for this endpoint so JavaScript can POST to it
  protect_from_forgery with: :null_session, only: [:run]

  def run
    language = params[:language]
    code = params[:code]
    custom_lang = params[:custom_language]

    # Validate inputs
    if code.blank?
      return render json: { success: false, output: "Error: No code provided" }
    end

    if language.blank?
      return render json: { success: false, output: "Error: No language specified" }
    end

    # Handle custom language input
    if language == "custom" && custom_lang.present?
      lang_config = {
        name: custom_lang[:name],
        image: custom_lang[:image],
        extension: custom_lang[:extension],
        command: custom_lang[:command]
      }
    else
      # Default supported languages
      lang_config = {
        "ruby" =>   { image: "ruby:3.3-alpine", extension: ".rb", command: "ruby" },
        "python" => { image: "python:3.12-alpine", extension: ".py", command: "python3" },
        "java" =>   { image: "openjdk:17-alpine", extension: ".java", command: "javac" },
        "javascript" => { image: "node:22-alpine", extension: ".js", command: "node" }
      }[language]
    end

    unless lang_config
      return render json: { success: false, output: "Unsupported language: #{language}" }
    end

    image = lang_config[:image]
    extension = lang_config[:extension]
    command = lang_config[:command]

    # Log execution
    Rails.logger.info "Executing #{language} code using #{image}"

    # Execute code in Docker container
    result = DockerRunner.run(language, code, image:, extension:, command:)

    render json: {
      success: result[:success],
      output: result[:output]
    }

  rescue => e
    Rails.logger.error "Code execution error: #{e.message}"
    render json: {
      success: false,
      output: "Server error: #{e.message}"
    }
  end
end
