class HomeController < ApplicationController
  # app/controllers/home_controller.rb (or PagesController)
  def index
    @user_pages = UserPage.all.order(created_at: :desc)
  end

end
