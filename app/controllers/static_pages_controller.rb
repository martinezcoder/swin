class StaticPagesController < ApplicationController
  def home
    if signed_in? 
      if approved?
        redirect_to user_path(current_user)
      else
        redirect_to edit_user_path(current_user)
      end
    end
  end

  def help
  end

  def about
  end

end
