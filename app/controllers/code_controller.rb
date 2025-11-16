# app/controllers/code_controller.rb
class CodeController < ApplicationController
  protect_from_forgery with: :null_session, only: [:run]

  def run
    language_name = params[:language]
    code = params[:code]
    custom_lang = params[:custom_language] || {}

    # Validate input
    if code.blank?
      return render json: { success: false, output: "Error: No code provided" }
    end

    if language_name.blank?
      return render json: { success: false, output: "Error: No language specified" }
    end

    lang_config = nil

    if language_name == "custom" && custom_lang.present?
      # Handle custom language from form upload
      lang_config = {
        image: custom_lang[:image].presence || "alpine:latest",
        extension: custom_lang[:extension].presence || ".txt",
        command: custom_lang[:command].presence || "cat"
      }
      language_name = custom_lang[:name].presence || "custom"
    else
      # Try to find language in DB first
      language = Language.find_by(name: language_name)

      if language
        lang_config = {
          image: language.image.presence || "alpine:latest",
          extension: language.extension.presence || ".txt",
          command: language.command.presence || "cat"
        }
      else
        # Fall back to hard-coded defaults for main languages
        lang_config = {
          "ruby" =>   { image: "ruby:3.3-alpine", extension: ".rb",  command: "ruby" },
          "python" => { image: "python:3.12-alpine", extension: ".py", command: "python3" },
          "java" =>   { image: "eclipse-temurin:17-jdk", extension: ".java", command: "sh -c 'javac Main.java && java Main'" },
          "javascript" => { image: "node:22-alpine", extension: ".js", command: "node" }
        }[language_name]
      end
    end

    unless lang_config
      return render json: { success: false, output: "✗ Unsupported language: #{language_name}" }
    end

    image = lang_config[:image]
    extension = lang_config[:extension]
    command = lang_config[:command]

    Rails.logger.info "🟢 Running #{language_name} with image=#{image}, ext=#{extension}, cmd=#{command}"

    result = DockerRunner.run(language_name, code, image: image, extension: extension, command: command)

    render json: { success: result[:success], output: result[:output] }
  rescue => e
    Rails.logger.error "❌ Code execution error: #{e.message}"
    render json: { success: false, output: "Server error: #{e.message}" }
  end
end
