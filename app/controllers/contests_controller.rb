class ContestsController < ApplicationController
 
  layout "application"
  
  before_filter :check_for_admin, :only => [:new, :create]
  #before_filter :load_user

  def dashboard
    @user_session = UserSession.new
    @user_session.email = flash[:email]
    @contests = Contest.find(:all, :order => 'created_at desc', :limit => 3)
  end
  
  def how_to    
  end
  
  # GET /contests
  # GET /contests.xml
  def index
    @contests = Contest.find(:all, :order => 'created_at desc')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contests }
    end
  end

  # GET /contests/1
  # GET /contests/1.xml
  def show
    @contest = Contest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contest }
    end
  end

  # GET /contests/new
  # GET /contests/new.xml
  def new
    @contest = Contest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contest }
    end
  end

  # GET /contests/1/edit
  def edit
    @contest = Contest.find(params[:id])
  end

  # POST /contests
  # POST /contests.xml
  def create
    @contest = Contest.new(params[:contest])
    @contest.user_id = current_user.id
    parse_and_create_teams(params[:teams]) if params[:teams]
      
    respond_to do |format|
      if @contest.save
        create_open_post
        flash[:notice] = 'Contest was successfully created.'
        format.html { redirect_to(contests_path) }
        format.xml  { render :xml => @contest, :status => :created, :location => @contest }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contest.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contests/1
  # PUT /contests/1.xml
  def update
    @contest = Contest.find(params[:id])

    respond_to do |format|
      if @contest.update_attributes(params[:contest])
        flash[:notice] = 'Contest was successfully updated.'
        format.html { redirect_to(contests_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contest.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contests/1
  # DELETE /contests/1.xml
  def destroy
    @contest = Contest.find(params[:id])
    @contest.destroy

    respond_to do |format|
      format.html { redirect_to(contests_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def create_open_post
    @post = Post.new
    @post.subject = @contest.name + " (open contest)"
    @post.url = @contest.url #|| params[:url] if params[:url]
    @post.description = @contest.description 
    @post.contest_id = @contest.id
    @post.unique_id = Post.generate_unique_id
    @post.user_id = current_user.id
    @post.save
    #@contest.update_attributes(:join_open_contest_link => @post.get_readonly_url(current_user))
  end
  
  def parse_and_create_teams(teamtext)
    team_array = []
    team_array.concat(teamtext.split(/,/))
    team_array.each do |team_name|
      @contest.teams << Team.new(:teamname => team_name.strip)
    end
  end 
end