# encoding: UTF-8

class PagesController < ApplicationController
  include PagesHelper

  def show
    @page = Page.find(params[:id])
    @engage = get_engage(@page.fan_count, @page.talking_about_count)
  end

end
