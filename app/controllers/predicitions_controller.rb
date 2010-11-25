class PredicitionsController < ApplicationController
  
  before_filter :load_prerequisite, :only => [:user_predicition, :admin_predicition, :show]
  
  def load_prerequisite
    @match = Match.find_by_unique_id(params[:mid], :include => :category) if params[:mid]
    #@user = User.find_by_unique_id(params[:uid]) if params[:uid]
    
    unless current_user && current_user.admin? && current_user.admin_user?
      @engagement = Engagement.find_by_unique_id(params[:eid]) if params[:eid]
      #@spectator = @user.spectators.find_by_match_id(@match.id)
      @spectator = Spectator.find_by_engagement_id_and_match_id(@engagement.id, @match.id)
    end

    @category = @match.category
    #@category = Category.find_by_id(@match.category_id)
  end
  
  
  def user_predicition
    @user_name = Engagement.find_by_id(@spectator.engagement_id).invitee.display_name
    predicition_details = ""
    predicition_details << "<b> #{@user_name}'s prediction:</b> <br/>"
    
    @category.entries.each do |entry|
        @predicition_record = Predicition.find_by_spectator_id_and_entry_id(@spectator.id, entry.id)      
        
        if entry.name == 'winner'
            @predicition_record.user_predicition = params[:winner] ? params[:winner] : -1
            predicition_details << "#{entry.name.capitalize}: #{Team.find_by_id(@predicition_record.user_predicition).teamname.capitalize} <br/>" if @predicition_record.user_predicition != -1
        end
        
        if entry.name == 'toss'
            @predicition_record.user_predicition = params[:toss] ? params[:toss] : -1
            predicition_details << "#{entry.name.capitalize}: #{Team.find_by_id(@predicition_record.user_predicition).teamname.capitalize} <br/>" if @predicition_record.user_predicition != -1
        end
        
        if entry.name == 'ts_firstteam'
            @predicition_record.user_predicition = params[:ts_firstteam] ? params[:ts_firstteam] : -1
            predicition_details << "Total Score #{get_teamname(@match.firstteam).capitalize}:  #{PredictTotalScore.find_by_id(@predicition_record.user_predicition).label_text} <br/>" if @predicition_record.user_predicition != -1
        end
        
        if entry.name == 'ts_secondteam'
            @predicition_record.user_predicition = params[:ts_secondteam] ? params[:ts_secondteam] : -1
            predicition_details << "Total Score #{get_teamname(@match.secondteam).capitalize}:  #{PredictTotalScore.find_by_id(@predicition_record.user_predicition).label_text} <br/>" if @predicition_record.user_predicition != -1
        end            
        
        if entry.name == 'win_margin_wicket'
            @predicition_record.user_predicition = params[:win_margin_wicket] ? params[:win_margin_wicket] : -1
            predicition_details << "Win Margin Wicket: #{Predicition::WIN_MARGIN_WICKET[@predicition_record.user_predicition]} <br/>" if @predicition_record.user_predicition != -1
        end
        
        if entry.name == 'win_margin_score'
            @predicition_record.user_predicition = params[:win_margin_score] ? params[:win_margin_score] : -1
            predicition_details << "Win Margin Score:  #{Predicition::WIN_MARGIN_SCORE[@predicition_record.user_predicition]} <br/>" if @predicition_record.user_predicition != -1
        end
        
        @predicition_record.save
    end
    
    render :update do |page|
      page.visual_effect :blind_up, 'facebox'
    end 

    if predicition_details.size > 0
        Predicition.predicition_notification(@engagement.post_id, @match, @user_name, predicition_details)
    end

  end
 
  
  def user_predicition1
    @category.entries.each do |entry|
        @predicition_record = Predicition.find_by_spectator_id_and_entry_id(@spectator.id, entry.id)      
        
        @predicition_record.user_predicition = params[:winner] ? params[:winner] : -1 if entry.name == 'winner'
        @predicition_record.user_predicition = params[:toss] ? params[:toss] : -1 if entry.name == 'toss'
        
        @predicition_record.user_predicition = params[:ts_firstteam] ? params[:ts_firstteam] : -1 if entry.name == 'ts_firstteam'
        @predicition_record.user_predicition = params[:ts_secondteam] ? params[:ts_secondteam] : -1 if entry.name == 'ts_secondteam'
        
        @predicition_record.user_predicition = params[:win_margin_wicket] ? params[:win_margin_wicket] : -1 if entry.name == 'win_margin_wicket'
        @predicition_record.user_predicition = params[:win_margin_score] ? params[:win_margin_score] : -1 if entry.name == 'win_margin_score'
        @predicition_record.save
    end
    
    render :update do |page|
      page.visual_effect :blind_up, 'facebox'
    end 
  end
 
  def admin_predicition
    @category.entries.each do |entry|
        @result = Result.find_by_match_id_and_entry_id(@match.id, entry.id)
        
        @result.result = params[:winner] ? params[:winner] : -1 if entry.name == 'winner'
        @result.result = params[:toss] ? params[:toss] : -1 if entry.name == 'toss'
        
        @result.result = params[:ts_firstteam] ? params[:ts_firstteam] : -1 if entry.name == 'ts_firstteam'
        @result.result = params[:ts_secondteam] ? params[:ts_secondteam] : -1 if entry.name == 'ts_secondteam'
        
        @result.result = params[:win_margin_wicket] ? params[:win_margin_wicket] : -1 if entry.name == 'win_margin_wicket'
        @result.result = params[:win_margin_score] ? params[:win_margin_score] : -1 if entry.name == 'win_margin_score'
 
        @result.save
    end

    render :update do |page|
      page.visual_effect :blind_up, 'facebox'
    end 
  end
  
  # GET /predicitions
  # GET /predicitions.xml
  def index
    @predicitions = Predicition.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @predicitions }
    end
  end

  # GET /predicitions/1
  # GET /predicitions/1.xml
  def show
    #@predicition = Predicition.find(params[:id])
    @totalscore_entries = PredictTotalScore.find(:all)
    
    respond_to do |format|
      format.html # show.html.erb
      #format.xml  { render :xml => @predicition }
      format.js { render_to_facebox }
    end
  end

  # GET /predicitions/new
  # GET /predicitions/new.xml
  def new
    @predicition = Predicition.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @predicition }
    end
  end

  # GET /predicitions/1/edit
  def edit
    @predicition = Predicition.find(params[:id])
  end

  # POST /predicitions
  # POST /predicitions.xml
  def create
    @predicition = Predicition.new(params[:predicition])

    respond_to do |format|
      if @predicition.save
        flash[:notice] = 'Predicition was successfully created.'
        format.html { redirect_to(@predicition) }
        format.xml  { render :xml => @predicition, :status => :created, :location => @predicition }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @predicition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /predicitions/1
  # PUT /predicitions/1.xml
  def update
    @predicition = Predicition.find(params[:id])

    respond_to do |format|
      if @predicition.update_attributes(params[:predicition])
        flash[:notice] = 'Predicition was successfully updated.'
        format.html { redirect_to(@predicition) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @predicition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /predicitions/1
  # DELETE /predicitions/1.xml
  def destroy
    @predicition = Predicition.find(params[:id])
    @predicition.destroy

    respond_to do |format|
      format.html { redirect_to(predicitions_url) }
      format.xml  { head :ok }
    end
  end
  
end