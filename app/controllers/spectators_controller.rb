class SpectatorsController < ApplicationController
  
  layout 'posts'
  #layout 'application'
  before_filter :load_prerequisite, :only => [:show, :result, :load_all_participants]
  before_filter :load_user, :only => [:show]
  
  def load_prerequisite_old
    unless params[:mid].nil? || params[:eid].nil?
        @match = Match.find_by_unique_id(params[:mid], :include => [:category, :contest]) if params[:mid]
        @eng = Engagement.find_by_unique_id(params[:eid], :include => [:post, :invitee]) if params[:eid]
        #@user = User.find(@eng.user_id)
        @user = @eng.invitee
        #@post = Post.find(@eng.post_id)    needed to display the matches on the spectator page
        @post = @eng.post
        #@contest = Contest.find(@post.contest_id) needed to display the matches on the spectator page
        @contest = @match.contest
        #@spectator = @user.spectators.find_by_match_id(@match.id)
        @spectator = Spectator.find_by_engagement_id_and_match_id(@eng.id, @match.id)
        #@category = Category.find(@match.category_id)
        @category = @match.category
    end
  end

  def load_prerequisite
    if !params[:mid].nil? 
        @match = Match.find_by_unique_id(params[:mid], :include => [:category, :contest]) if params[:mid]
        @contest = @match.contest
        @category = @match.category
    end
    
    if !params[:eid].nil?
        @eng = Engagement.find_by_unique_id(params[:eid], :include => [:post, :invitee])
        @user = @eng.invitee
        @post = @eng.post
        @spectator = Spectator.find_by_engagement_id_and_match_id(@eng.id, @match.id)
    end
  end

  def load_user
     unless params[:mid].nil? || params[:eid].nil?
        if current_user && current_user.activated?
            #Now check if this is the same user as the logged in user
            #If not, then logout the current_user
            force_logout if @user && @user.id != current_user.id
        else
            #load the user based on the unique id
            #if user is member, so force login
            if @user && @user.activated?
                flash[:notice] = "Please login and you will be on your way."
                flash[:email] = @user.email
                store_location if action_name == 'show'  #we do not want to store if it is any other action
                redirect_to login_path
            end
        end
        if @user.nil?
            flash[:error] = "Your identity could not be confirmed from the link that you provided. <br/> Please request the inviter to resend the link."
            force_logout
            redirect_to root_path
        end
    end
  end           
      
  def load_all_participants
       #@post = params[:pid] ? Post.find_by_unique_id(params[:pid]) : nil
       render :partial => 'participants_list'
  end
  
  # GET /spectators
  # GET /spectators.xml  
  def index
    @spectators = Spectator.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @spectators }
    end
  end

  # GET /spectators/1
  # GET /spectators/1.xml
  def show
    #@spectator = Spectator.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @spectator }
    end
  end

  def result
    respond_to do |format|
      format.html # show.html.erb
      #format.xml  { render :xml => @spectator }
      format.js { render_to_facebox }
    end   
  end
  
  # GET /spectators/new
  # GET /spectators/new.xml
  def new
    @spectator = Spectator.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @spectator }
    end
  end

  # GET /spectators/1/edit
  def edit
    @spectator = Spectator.find(params[:id])
  end

  # POST /spectators
  # POST /spectators.xml
  def create
    @spectator = Spectator.new(params[:spectator])

    respond_to do |format|
      if @spectator.save
        flash[:notice] = 'Spectator was successfully created.'
        format.html { redirect_to(@spectator) }
        format.xml  { render :xml => @spectator, :status => :created, :location => @spectator }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @spectator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /spectators/1
  # PUT /spectators/1.xml
  def update
    @spectator = Spectator.find(params[:id])

    respond_to do |format|
      if @spectator.update_attributes(params[:spectator])
        flash[:notice] = 'Spectator was successfully updated.'
        format.html { redirect_to(@spectator) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @spectator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /spectators/1
  # DELETE /spectators/1.xml
  def destroy
    @spectator = Spectator.find(params[:id])
    @spectator.destroy

    respond_to do |format|
      format.html { redirect_to(spectators_url) }
      format.xml  { head :ok }
    end
  end
end
