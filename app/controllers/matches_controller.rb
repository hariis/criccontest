class MatchesController < ApplicationController
  
  layout 'application'
  
  before_filter :load_contest
  #before_filter :load_user
  before_filter :check_for_admin, :except => [:index, :show]
  
  def load_contest
    @contest = Contest.find_by_id(params[:contest_id]) if params[:contest_id]
  end
  
  #def load_post
  #  @post = Post.find_by_id(params[:post_id]) if params[:post_id]
  #end
  
  def load_user
    #@user = User.find_by_id(params[:user_id]) if params[:user_id]
    #TODO
    #@user = current_user if current_user && current_user.activated?
  end
  
  # GET /matches
  # GET /matches.xml
  def index
    @matches = @contest.matches

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @matches }
    end
  end

  # GET /matches/1
  # GET /matches/1.xml
  def show
    @match = @contest.matches.find(params[:id])
      
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @match }
    end
  end

  # GET /matches/new
  # GET /matches/new.xml
  def new
    @match = @contest.matches.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @match }
    end
  end

  # GET /matches/1/edit
  def edit
    @match = @contest.matches.find(params[:id])
  end

  # POST /matches
  # POST /matches.xml
  def create
    @match = @contest.matches.build(params[:match])
    #@match.user_id = @user.id unless @user.nil?
    @match.user_id = current_user.id unless current_user.nil?
    @match.contest_id = @contest.id
    @match.category_id = params[:category] if params[:category]
    @match.unique_id = Match.generate_unique_id
    
    respond_to do |format|
      if @match.save
        flash[:notice] = 'Match was successfully created.'
        @match.create_all_entries_for_the_match(@contest)
        #create_result_table(@match)
        format.html { redirect_to(@contest) }
        format.xml  { render :xml => @match, :status => :created, :location => @match }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @match.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /matches/1
  # PUT /matches/1.xml
  def update
    @match = @contest.matches.find(params[:id])

    respond_to do |format|
      if @match.update_attributes(params[:match])
        flash[:notice] = 'Match was successfully updated.'
        format.html { redirect_to(contest_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @match.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /matches/1
  # DELETE /matches/1.xml
  def destroy
    @match = @contest.matches.find(params[:id])
    @match.destroy

    respond_to do |format|
      format.html { redirect_to(@contest) }
      format.xml  { head :ok }
    end
  end
  
  def calculate_match_result
     if current_user && current_user.admin? && current_user.admin_user?     
         match = @contest.matches.find(params[:id])
         category = Category.find_by_id(match.category_id)
         
         @contest.posts.each do |post|
            post.engagements.each do |engagement|
                spectator = engagement.spectators.find_by_match_id(match.id) 
                #spectator = Spectator.find(:first, :conditions => ['match_id = ? && engagement_id = ?', match.id, engagement.id])
                if spectator
                   @total_score = 0
                   category.entries.each do |entry|
                      #calculate_prediction_result('winner')
                      #if entry.name == 'winner'
                      predicition = Predicition.find_by_spectator_id_and_entry_id(spectator.id, entry.id)
                      result = Result.find_by_match_id_and_entry_id(match.id, entry.id)

                      if predicition.user_predicition == result.result
                          predicition.score = entry.posweight
                      else
                          predicition.score = entry.negweight          
                      end        
                      predicition.save
                      #end
                      @total_score += predicition.score
                   end
                   spectator.totalscore = @total_score
                   spectator.save
                end
            end
         end 
         set_contest_score   #set score for all the user's participating in this contest
         #redirect_to :controller => 'spectators', :action => 'show', :mid => @match.unique_id, :uid => current_user.unique_id
         #render 'show'
         flash[:notice] = "Results have been updated"
         redirect_to contest_path(@contest)
     end
  end
  
  def set_contest_score
    @contest.posts.each do |post|
      post.engagements.each do |engagement|
        totalscore = 0
        engagement.spectators.each do |spectator|
          totalscore += spectator.totalscore if spectator
        end
        engagement.totalscore = totalscore
        engagement.save
      end
    end
  end

end
