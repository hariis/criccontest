class PredicitionsController < ApplicationController
  
  before_filter :load_prerequisite, :only => [:user_predicition, :admin_predicition, :show]
  #TODO before_filter :redirect_to_error, :except => [:user_predicition, :admin_predicition, :show]
  
  #-----------------------------------------------------------------------------------------------------
  def redirect_to_error
    render 'posts/404', :status => 404, :layout => false and return
  end
  
  #-----------------------------------------------------------------------------------------------------  
  def load_prerequisite
    @match = Match.find_by_unique_id(params[:mid], :include => :category) if params[:mid]
    #@category = @match.category if @match
    @entries = Entry.find(:all)
    
    unless current_user && current_user.admin? && current_user.admin_user?
      if params[:eid]
        @engagement = Engagement.find_by_unique_id(params[:eid]) 
        @spectator = Spectator.find_by_engagement_id_and_match_id(@engagement.id, @match.id)
      end
    end
  end
  
  #-----------------------------------------------------------------------------------------------------
  def user_predicition
    #@user_name = Engagement.find_by_id(@spectator.engagement_id).invitee.display_name
    if !@match.check_if_match_started
        @user_name = @engagement.invitee.display_name

        predicition_details = ""
        prediction_count = 0
        predicition_details << "<span style='color:#21519C;font-weight:bold'> #{@user_name}'s prediction: </span><br/>"

        #@category.entries.each do |entry|
        @entries.each do |entry|
            @predicition_record = Predicition.find_by_spectator_id_and_entry_id(@spectator.id, entry.id)      

            if entry.name == 'winner'
                @predicition_record.user_predicition = params[:winner] ? params[:winner] : -1
                if params[:winner]
                    prediction_count += 1
                    predicition_details << "#{entry.name.capitalize}: #{Team.find_by_id(@predicition_record.user_predicition).teamname} <br/>"
                end
            end

            if entry.name == 'toss'
                @predicition_record.user_predicition = params[:toss] ? params[:toss] : -1
                if params[:toss]
                    prediction_count += 1
                    predicition_details << "#{entry.name.capitalize}: #{Team.find_by_id(@predicition_record.user_predicition).teamname} <br/>"
                end
            end

            if entry.name == 'ts_firstteam'
                @predicition_record.user_predicition = params[:ts_firstteam] ? params[:ts_firstteam] : -1
                if params[:ts_firstteam]
                    prediction_count += 1
                    if @match.category.name == 'Twenty20 match'
                        predicition_details << "Total Score #{get_teamname(@match.firstteam)}:   #{Predicition::PREDICT_TOTAL_SCORE_TWENTY20[@predicition_record.user_predicition - 1]} <br/>"
                    else
                        predicition_details << "Total Score #{get_teamname(@match.firstteam)}:  #{PredictTotalScore.find_by_id(@predicition_record.user_predicition).label_text} <br/>"
                    end
                end
            end

            if entry.name == 'ts_secondteam'
                @predicition_record.user_predicition = params[:ts_secondteam] ? params[:ts_secondteam] : -1
                if  params[:ts_secondteam]
                    prediction_count += 1
                    if @match.category.name == 'Twenty20 match'
                        predicition_details << "Total Score #{get_teamname(@match.secondteam)}:   #{Predicition::PREDICT_TOTAL_SCORE_TWENTY20[@predicition_record.user_predicition - 1]} <br/>"
                    else
                        predicition_details << "Total Score #{get_teamname(@match.secondteam)}:  #{PredictTotalScore.find_by_id(@predicition_record.user_predicition).label_text} <br/>"
                    end
                end
            end            

            if entry.name == 'win_margin_wicket'
                @predicition_record.user_predicition = params[:win_margin_wicket] ? params[:win_margin_wicket] : -1
                if params[:win_margin_wicket]
                    prediction_count += 1
                    predicition_details << "Win Margin Wicket: #{Predicition::WIN_MARGIN_WICKET[@predicition_record.user_predicition]} <br/>"
                end
            end

            if entry.name == 'win_margin_score'
                @predicition_record.user_predicition = params[:win_margin_score] ? params[:win_margin_score] : -1
                if params[:win_margin_score]
                    prediction_count += 1
                    if @match.category.name == 'Twenty20 match'
                        predicition_details << "Win Margin Score:  #{Predicition::WIN_MARGIN_SCORE_TWENTY20[@predicition_record.user_predicition]} <br/>"
                    else
                        predicition_details << "Win Margin Score:  #{Predicition::WIN_MARGIN_SCORE[@predicition_record.user_predicition]} <br/>"
                    end
                end
            end

            @predicition_record.save
        end
    end
    
    render :update do |page|
      if current_user && current_user.admin? && current_user.admin_user?
        page.visual_effect :blind_up, 'facebox'
      else
        if @match.check_if_match_started
          page.replace_html "prediction-status", "Timeline for predicting this match is over</b>."
        elsif prediction_count != 6
           page.replace_html "prediction-status", "It seems that are missing few predictions.<br/> Please add your input for all the options."
        else
           page.replace_html "prediction_details_#{@engagement.id}", predicition_details           
           page.visual_effect :blind_up, 'facebox'         
        end
      end
    end 

     #Overide the prediction text to just display the text below in email notification.
     #if !@match.check_if_match_started
     #   predicition_details = "Prediction will be displayed once the match begin"
     #end
    
    if prediction_count == 6 && predicition_details.size > 0
        Predicition.predicition_notification(@engagement.post_id, @match, @user_name, predicition_details)
    end
  end

  #-----------------------------------------------------------------------------------------------------  
  def admin_predicition
    match_result = params[:match_result] ? params[:match_result] : "Results not yet updated"
    @match.update_attributes(:match_result => match_result)

    #@category.entries.each do |entry|
    @entries.each do |entry|
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
  
  #-----------------------------------------------------------------------------------------------------
  # GET /predicitions
  # GET /predicitions.xml
  def index
    @predicitions = Predicition.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @predicitions }
    end
  end

  #-----------------------------------------------------------------------------------------------------
  # GET /predicitions/1
  # GET /predicitions/1.xml
  def show
    #@predicition = Predicition.find(params[:id])
    @totalscore_entries = PredictTotalScore.find(:all)
    @readonlypost = params[:iid].nil? ? false : true
    
    respond_to do |format|
      format.html # show.html.erb
      #format.xml  { render :xml => @predicition }
      format.js { render_to_facebox }
    end
  end

  #-----------------------------------------------------------------------------------------------------
  # GET /predicitions/new
  # GET /predicitions/new.xml
  def new
    @predicition = Predicition.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @predicition }
    end
  end

  #-----------------------------------------------------------------------------------------------------
  # GET /predicitions/1/edit
  def edit
    @predicition = Predicition.find(params[:id])
  end

  #-----------------------------------------------------------------------------------------------------
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

  #-----------------------------------------------------------------------------------------------------
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

  #-----------------------------------------------------------------------------------------------------
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
  
  #-----------------------------------------------------------------------------------------------------
end