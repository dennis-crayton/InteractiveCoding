# app/controllers/user_pages_controller.rb
class UserPagesController < ApplicationController
  # Browse all user-created pages
  def index
    @user_pages = UserPage.order(created_at: :desc)
  end
  
  # Form to create new page
  def new
    @user_page = UserPage.new
  end
  
  # Create new user page
  def create
    @user_page = UserPage.new(user_page_params)
    
    if @user_page.save
      redirect_to user_page_path(@user_page), notice: "Page created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  # View a specific user page
  def show
    @user_page = UserPage.find(params[:id])
  end
  
  # Download page as JSON file
  def download
    @user_page = UserPage.find(params[:id])
    @user_page.increment_downloads!
    
    send_data @user_page.to_export.to_json,
              filename: "#{@user_page.title.parameterize}-tutorial.json",
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

  # Show upload form
  def upload_form
  end
  
  # Upload a downloaded page
  def upload
    uploaded_file = params[:file]

    if uploaded_file.nil?
      return render json: { success: false, error: "Please select a file to upload" }, status: :unprocessable_entity
    end

    begin
      file_content = uploaded_file.read
      json_data = JSON.parse(file_content)
      @user_page = UserPage.from_export(json_data)

      if @user_page.save
        # Return JSON with success flag and card data
        render json: {
          success: true,
          id: @user_page.id,
          title: @user_page.title,
          language: @user_page.language,
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
    params.require(:user_page).permit(:title, :language, :author, :description, :content)
  end
end