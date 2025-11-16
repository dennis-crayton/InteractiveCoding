# app/controllers/user_pages_controller.rb
class UserPagesController < ApplicationController
  before_action :ensure_default_languages, only: [:new, :create]

  def index
    @user_pages = UserPage.order(created_at: :desc)
  end

  def new
    @user_page = UserPage.new
  end

  def create
    raw_content = params[:user_page][:content]
    parsed_content = JSON.parse(raw_content) rescue {}

    language_data = parsed_content["language"] || {}
    language_name = language_data["name"]

    language = Language.find_or_create_by(name: language_name) do |lang|
      lang.image = language_data["image"]
      lang.extension = language_data["extension"]
      lang.command = language_data["command"]
    end

    @user_page = UserPage.new(
      title: params[:user_page][:title],
      author: params[:user_page][:author],
      description: params[:user_page][:description],
      accent_color: parsed_content["accent_color"],
      language: language
    )

    if @user_page.save
      # Handle both formats: separate arrays OR mixed array with type
      all_sections = parsed_content["sections"] || []
      
      all_sections.each do |block|
        case block["type"]
        when "section"
          @user_page.sections.create!(title: block["title"], content: block["content"])
        when "code"
          @user_page.code_examples.create!(title: block["title"], code: block["code"])
        when "exercise"
          @user_page.exercises.create!(title: block["title"], prompt: block["prompt"], starter_code: block["starter_code"])
        end
      end

      redirect_to user_page_path(@user_page), notice: "Tutorial created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user_page = UserPage.find(params[:id])
  end

  def download
    @user_page = UserPage.find(params[:id])
    
    # Builds complete JSON with type field for each item
    all_sections = []
    
    @user_page.sections.each do |s|
      all_sections << {
        type: "section",
        title: s.title,
        content: s.content
      }
    end
    
    @user_page.code_examples.each do |c|
      all_sections << {
        type: "code",
        title: c.title,
        code: c.code
      }
    end
    
    @user_page.exercises.each do |e|
      all_sections << {
        type: "exercise",
        title: e.title,
        prompt: e.prompt,
        starter_code: e.starter_code
      }
    end
    
    data = {
      title: @user_page.title,
      author: @user_page.author,
      description: @user_page.description,
      accent_color: @user_page.accent_color,
      language: {
        name: @user_page.language&.name,
        image: @user_page.language&.image,
        extension: @user_page.language&.extension,
        command: @user_page.language&.command
      },
      sections: all_sections 
    }
    
    send_data data.to_json,
              filename: "#{@user_page.title.parameterize}.json",
              type: 'application/json',
              disposition: 'attachment'
  end

  def destroy
    @user_page = UserPage.find_by(id: params[:id])
    if @user_page&.destroy
      render json: { success: true }
    else
      render json: { success: false, error: "Could not delete tutorial" }, status: :unprocessable_entity
    end
  end

  def upload_form; end

  def upload
    uploaded_file = params[:file]

    if uploaded_file.nil?
      return render json: { success: false, error: "Please select a file to upload" }, status: :unprocessable_entity
    end

    begin
      file_content = uploaded_file.read
      json_data = JSON.parse(file_content)

      language_data = json_data["language"]
      language = Language.find_or_create_by(name: language_data["name"]) do |lang|
        lang.image = language_data["image"]
        lang.extension = language_data["extension"]
        lang.command = language_data["command"]
      end

      @user_page = UserPage.new(
        title: json_data["title"],
        author: json_data["author"],
        description: json_data["description"],
        accent_color: json_data["accent_color"],
        language: language
      )

      if @user_page.save
        # Handle mixed array with type field
        all_sections = json_data["sections"] || []
        
        all_sections.each do |block|
          case block["type"]
          when "section"
            @user_page.sections.create!(title: block["title"], content: block["content"])
          when "code"
            @user_page.code_examples.create!(title: block["title"], code: block["code"])
          when "exercise"
            @user_page.exercises.create!(title: block["title"], prompt: block["prompt"], starter_code: block["starter_code"])
          end
        end

        render json: {
          success: true,
          id: @user_page.id,
          title: @user_page.title,
          language: @user_page.language.name,
          author: @user_page.author,
          description: @user_page.description
        }
      else
        render json: { success: false, error: @user_page.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    rescue JSON::ParserError
      render json: { success: false, error: "Invalid JSON file" }, status: :unprocessable_entity
    rescue => e
      render json: { success: false, error: "Error uploading file: #{e.message}" }, status: :unprocessable_entity
    end
  end

  private

  def user_page_params
    params.require(:user_page).permit(:title, :author, :description, :accent_color, :language_id, :content)
  end

  # Preload default languages so dropdown always works
  def ensure_default_languages
    default_langs = [
      { name: "ruby",   image: "ruby:3.3-alpine",   extension: ".rb",  command: "ruby" },
      { name: "python", image: "python:3.12-alpine", extension: ".py", command: "python3" },
      { name: "java",   image: "eclipse-temurin:17-jdk", extension: ".java", command: "sh -c 'javac Main.java && java Main'" }
    ]

    default_langs.each do |lang|
      Language.find_or_create_by(name: lang[:name]) do |l|
        l.image = lang[:image]
        l.extension = lang[:extension]
        l.command = lang[:command]
      end
    end
  end
end
