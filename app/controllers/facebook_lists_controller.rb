class FacebookListsController < ApplicationController

  before_filter :signed_in_user
  # GET /facebook_lists
  # GET /facebook_lists.json
  def index
    @facebook_lists = FacebookList.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @facebook_lists }
    end
  end

  # GET /facebook_lists/1
  # GET /facebook_lists/1.json
  def show
    @facebook_lists = FacebookList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @facebook_lists }
    end
  end

  # GET /facebook_lists/1/edit
  def edit
    @facebook_list = FacebookList.find(params[:id])
  end

  # PUT /facebook_lists/1
  # PUT /facebook_lists/1.json
  def update
    @facebook_list = FacebookList.find(params[:id])

    respond_to do |format|
      if @facebook_list.update_attributes(params[:facebook_list])
        format.html { redirect_to @facebook_list, notice: 'List was successfully updated.' }
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
    @facebook_list = FacebookList.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @facebook_list }
    end
  end

  # POST /facebook_lists
  # POST /facebook_lists.json
  def create
    @facebook_list = FacebookList.new(params[:user])

    respond_to do |format|
      if @facebook_list.save
        format.html { redirect_to @facebook_list, notice: 'User was successfully created.' }
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
    @facebook_lists = FacebookList.find(params[:id])
    @facebook_lists.destroy

    respond_to do |format|
      format.html { redirect_to facebook_lists_url }
      format.json { head :no_content }
    end
  end
end
