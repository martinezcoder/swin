class FacebookListsController < ApplicationController

  before_filter :signed_in_user
  before_filter :is_user_list, except: [:new, :create, :index]


  def activate
    facebook_list = current_user.facebook_lists.find(params[:id])
    set_active_list(facebook_list.id)

    respond_to do |format|
        format.html { redirect_to facebook_lists_path }
        format.json { head :no_content }
    end
  end


  # GET /facebook_lists
  # GET /facebook_lists.json
  def index
    @facebook_lists = current_user.facebook_lists

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @facebook_lists }
    end
  end

  # GET /facebook_lists/1/edit
  def edit
    @facebook_list = current_user.facebook_lists.find(params[:id])

    @competitors = @facebook_list.pages.order("created_at DESC")
    @more =  MAX_COMPETITORS - @competitors.count

    fb_list = nil
    if params.has_key?(:search) && params[:search] != ""
      pages_ids_list = fb_get_search_pages_list(params[:search])      
      fb_list = fb_get_pages_info(pages_ids_list)
      @pageslist = []
      fb_list.each do |p|
        page = Page.find_by_page_id(p["page_id"].to_s)
        if page.nil?
          page = Page.new
          page.page_id             = p["page_id"]
          page.pic_square          = p["pic_square"]
          page.name                = p["name"]
          page.page_url            = p["page_url"]
          page.page_type           = p["type"]
          page.fan_count           = p["fan_count"]
          page.talking_about_count = p["talking_about_count"]          
        end
        @pageslist = @pageslist + [page]
      end
    end
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: { list: @facebook_list, competitors: @competitors }}
    end
  end

  # PUT /facebook_lists/1
  # PUT /facebook_lists/1.json
  def update
    @facebook_list = current_user.facebook_lists.find(params[:id])

    respond_to do |format|
      if @facebook_list.update_attributes(params[:facebook_list])
        format.html { redirect_to facebook_lists_path }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @facebook_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /facebook_lists/new
  # GET /facebook_lists/new.json
  def new
    @facebook_list = current_user.facebook_lists.build(page_id: 35)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @facebook_list }
    end
  end

  # POST /facebook_lists
  # POST /facebook_lists.json
  def create
    @facebook_list = current_user.facebook_lists.build(params[:facebook_list])
    
    respond_to do |format|
      if @facebook_list.save
        format.html { redirect_to edit_facebook_list_path(@facebook_list) }
        format.json { render json: @facebook_list, status: :created, location: @facebook_list }
      else
        format.html { render action: "new" }
        format.json { render json: @facebook_list.errors, status: :unprocessable_entity }
      end
    end

  end


  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @facebook_lists = current_user.facebook_lists.find(params[:id])
    @facebook_lists.destroy

    respond_to do |format|
      format.html { redirect_to facebook_lists_url }
      format.json { head :no_content }
    end
  end

private
  def is_user_list 
    list = FacebookList.find(params[:id])
    redirect_to facebook_lists_url if current_user.facebook_lists.find_by_id(list).nil?
  end


end
