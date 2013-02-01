class SessionsController < ApplicationController

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user
      sign_in user
      redirect_to user
    else
      # Create an error message and re-render the signin form.
      flash.now[:error] = 'Invalid email/password combination'
      redirect_to root_url
    end
  end

  def destroy    
  end

end
