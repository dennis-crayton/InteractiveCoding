# app/controllers/code_controller.rb
class CodeController < ApplicationController
  # Disable CSRF protection for this endpoint so JavaScript can POST to it
  protect_from_forgery with: :null_session, only: [:run]
  
  def run
    language = params[:language]
    code = params[:code]
    
    # Validate inputs
    if code.blank?
      return render json: { 
        success: false, 
        output: "Error: No code provided" 
      }
    end
    
    if language.blank?
      return render json: { 
        success: false, 
        output: "Error: No language specified" 
      }
    end
    
    # Log the execution attempt
    Rails.logger.info "Executing #{language} code: #{code[0..50]}..."
    
    # Execute code in Docker container
    result = DockerRunner.run(language, code)
    
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