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
  
  # Show upload form
  def upload_form
  end
  
  # Upload a downloaded page
  def upload
    uploaded_file = params[:file]
    
    if uploaded_file.nil?
      redirect_to user_pages_upload_form_path, alert: "Please select a file to upload"
      return
    end
    
    begin
      # Read and parse JSON
      file_content = uploaded_file.read
      json_data = JSON.parse(file_content)
      
      # Create new page from imported data
      @user_page = UserPage.from_export(json_data)
      
      if @user_page.save
        redirect_to user_page_path(@user_page), notice: "Page uploaded successfully!"
      else
        redirect_to user_pages_upload_form_path, alert: "Invalid page data: #{@user_page.errors.full_messages.join(', ')}"
      end
    rescue JSON::ParserError
      redirect_to user_pages_upload_form_path, alert: "Invalid JSON file"
    rescue => e
      redirect_to user_pages_upload_form_path, alert: "Error uploading file: #{e.message}"
    end
  end
  
  private
  
  def user_page_params
    params.require(:user_page).permit(:title, :language, :author, :description, :content)
  end
end