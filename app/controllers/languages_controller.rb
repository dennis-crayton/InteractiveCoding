class LanguagesController < ApplicationController
  def ruby
    # Redirect to first concept page
    redirect_to "/languages/ruby/1"
  end

  def python
    # Redirect to first concept page
    redirect_to "/languages/python/1"
  end

  def java
    # Redirect to first concept page (if you create java concepts later)
    redirect_to "/languages/java/1"
  end

  def ruby_concept
    @current_page = params[:page].to_i
    @max_pages = 7
    
    # Redirect to first page if invalid page number
    if @current_page < 1 || @current_page > @max_pages
      redirect_to "/languages/ruby/1" and return
    end
    
    render "languages/ruby_concepts/ruby#{@current_page}"
  end

  def python_concept
    @current_page = params[:page].to_i
    @max_pages = 7
    
    # Redirect to first page if invalid page number
    if @current_page < 1 || @current_page > @max_pages
      redirect_to "/languages/python/1" and return
    end
    
    render "languages/python_concepts/python#{@current_page}"
  end

  
end
