class PagesController < ApplicationController
  include PagesHelper

  before_filter :correct_user

  def index
    pages_update_from_facebook
    
    @user = User.find(params[:user_id])
    @pages = @user.pages
  end

  def search
  end


  private

    def correct_user
      begin
        @user = User.find(params[:user_id])
        redirect_to user_pages_path(current_user) unless current_user?(@user)
      rescue
        redirect_to user_pages_path(current_user)
      end
    end

end
