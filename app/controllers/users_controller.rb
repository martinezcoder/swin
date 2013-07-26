# encoding: UTF-8

class UsersController < ApplicationController
  include PagesHelper

  before_filter :user_is_admin, only: [:admin_query]

  # it will rend a graph with the evolution of the number of users by date
  def admin_query
    @ndays = params[:days] || 62

    days = (@ndays).to_i
    render :json => {
      :type => 'ColumnChart',
      :cols => [['string', 'Fecha'], ['number', 'users']],
      :rows => (1..days).to_a.inject([]) do |memo, i|
                  date = i.days.ago.to_date
                  t = date.strftime("%Y%m%d")
                  users = User.where("to_char(created_at, 'YYYYMMDD') = '#{t}'").count
                  memo << [date, users]
                  memo
                end.reverse,
      :options => {
        :chartArea => { :width => '80%', :height => '75%'},
        :hAxis => { :showTextEvery => 30 }
      }
    }
  end


  def new
    omniauth = session[:omniauth]
    @user = User.new(name: omniauth['info']['name'], email: omniauth['info']['email'] ||= nil)
  end

  def create
    @user = User.new(params[:user])
    if params[:user]["terms_of_service"] == '1'  
      if @user.save!
        sign_in @user
        @omniauth = session[:omniauth]
        session.delete(:omniauth)
        create_new_auth
        turn_on_auth
        redirect_to facebook_lists_path
      end
    else
      flash[:info] = 'No ha aceptado las condiciones de registro'
      render "new"
    end
  end

=begin
  before_filter :signed_in_user, only: [:show]
  before_filter :correct_user,  only: [:show]


  def show
    @user = User.find(params[:id])
  end

  private

    def correct_user
      begin
        @user = User.find(params[:id])
        redirect_to user_path(current_user) unless current_user?(@user)
      rescue
        redirect_to user_path(current_user)
      end
    end
=end

end
