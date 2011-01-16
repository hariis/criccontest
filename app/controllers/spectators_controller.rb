class SpectatorsController < ApplicationController
  
  layout 'posts', :except => [:fb_callback]
  before_filter :load_prerequisite, :only => [:show, :result, :load_all_participants]
  #before_filter :load_user, :only => [:show]
 
  #-----------------------------------------------------------------------------------------------------
  def load_prerequisite
    
    unless params[:mid].nil? 
        @match = Match.find_by_unique_id(params[:mid], :include => [:category, :contest]) if params[:mid]
        @contest = @match.contest
        @category = @match.category
    
        unless params[:eid].nil?
            @eng = Engagement.find_by_unique_id(params[:eid], :include => [:post, :invitee])
            @user = @eng.invitee
            @post = @eng.post
            @spectator = Spectator.find_by_engagement_id_and_match_id(@eng.id, @match.id)
        end
 
        if params[:eid].nil? && !params[:iid].nil?
            #@inviter = User.get_open_contest_inviter
            @inviter = User.find_by_unique_id(params[:iid])         
            @post = Post.get_open_contest(@contest, @inviter)
            
            @eng = Engagement.find_by_post_id_and_user_id(@post.id, @inviter.id, :include => [:post, :invitee])
            @spectator = @eng.spectators.find_by_match_id(@match.id) unless @eng.nil?
            @readonlypost = true
            @user = User.new
            @inviter_unique_id = params[:iid]  #this is required to craft link for displaying join_conversation_facebox    

            #if current_user && current_user.activated?
              #check if user is already a participant
            #  @eng = current_user.engagements.find_by_post_id(@post.id)
            #  url = @match.get_url_for(@eng, 'show')
            #  redirect_to(@match.get_url_for(@eng, 'show')) && return unless @eng.nil?
            #  return
            #end
        end      
    end
  end

  #-----------------------------------------------------------------------------------------------------
  def load_user  #TODO to be deleted. Is is not used.
    unless params[:mid].nil? 
      if !params[:eid].nil?
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
      else
         @readonlypost = false
         if params[:iid]
             #If iid is present in url, then it is a shared/open contest
             @user = User.new
         end
         @readonlypost = true
         @inviter_unique_id = params[:iid]  #this is required to craft link for displaying join_conversation_facebox              
      end
    end           
  end
    
  #-----------------------------------------------------------------------------------------------------  
  def load_all_participants
    render :partial => 'participants_list'
  end
  
  #-----------------------------------------------------------------------------------------------------
  # GET /spectators
  # GET /spectators.xml  
  def index
    @spectators = Spectator.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @spectators }
    end
  end

  #-----------------------------------------------------------------------------------------------------
  # GET /spectators/1
  # GET /spectators/1.xml
  def show 
    #@last_viewed_at = Time.now
    if @readonlypost && current_user && current_user.activated?
      #check if user is already a participant
      @eng = current_user.engagements.find_by_post_id(@post.id)
      redirect_to(@match.get_url_for(@eng, 'show')) && return unless @eng.nil?
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @spectator }
    end
  end

  #-----------------------------------------------------------------------------------------------------
  def result
    respond_to do |format|
      format.html # show.html.erb
      #format.xml  { render :xml => @spectator }
      format.js { render_to_facebox }
    end   
  end
  
  #-----------------------------------------------------------------------------------------------------
  # GET /spectators/new
  # GET /spectators/new.xml
  def new
    @spectator = Spectator.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @spectator }
    end
  end

  #-----------------------------------------------------------------------------------------------------
  # GET /spectators/1/edit
  def edit
    @spectator = Spectator.find(params[:id])
  end

  #-----------------------------------------------------------------------------------------------------
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

  #-----------------------------------------------------------------------------------------------------
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

  #-----------------------------------------------------------------------------------------------------
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
  
  #-----------------------------------------------------------------------------------------------------
 #Facebook
 def fb_authorize  
    redirect_to OAuthClient.web_server.authorize_url(
      :redirect_uri => auth_callback_url,
      :scope => 'email, offline_access, publish_stream'
    )
 end

 #-----------------------------------------------------------------------------------------------------
 def fb_callback
    begin
      access_token = OAuthClient.web_server.access_token(
        params[:code], :redirect_uri => auth_callback_url
      )  
      
      if session[:user_id]
        user_id = session[:user_id]
        session[:user_id] = nil
      end
      
      @fb_user = FacebookUser.create_from_fb(access_token, user_id)

      if session[:prediction]
        prediction_text = session[:prediction] 
        wall_message = prediction_text.gsub("<br/>", "\n")
        session[:prediction] = nil
      end

      @fb_user.post(wall_message)
      @status_msg = "Your prediction has been successfully posted to your Facebook Profile. <br/>
                        Please close this window and proceed with your contest."
      rescue => err
        RAILS_DEFAULT_LOGGER.error "Failed to get callback from Facebook" + err
        @status_msg = "There was a problem posting your prediction to your Profile. <br/>
                        Please close this window and try again later."

    end
 end
 
#-----------------------------------------------------------------------------------------------------
end
