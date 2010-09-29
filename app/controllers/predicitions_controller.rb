class PredicitionsController < ApplicationController
  
  before_filter :load_prerequisite, :only => [:user_predicition, :admin_predicition, :show]
  
  def load_prerequisite
    @match = Match.find_by_unique_id(params[:mid]) if params[:mid]
    #@user = User.find_by_unique_id(params[:uid]) if params[:uid]
    
    unless current_user && current_user.admin? && current_user.admin_user?
      @engagement = Engagement.find_by_unique_id(params[:eid]) if params[:eid]
      #@spectator = @user.spectators.find_by_match_id(@match.id)
      @spectator = Spectator.find_by_engagement_id_and_match_id(@engagement.id, @match.id)
    end

    @category = Category.find_by_id(@match.category_id)
  end
  
  def user_predicition
    @category.entries.each do |entry|
      if entry.name == 'winner'
        @predicition_record = Predicition.find_by_spectator_id_and_entry_id(@spectator.id, entry.id)
        @predicition_record.user_predicition = params[:winner]
        @predicition_record.save
      end
    end
    
    render :update do |page|
      page.visual_effect :blind_up, 'facebox'
      #page.replace_html 'predictions'
    end 
  end
 
  def admin_predicition
    @category.entries.each do |entry|
      if entry.name == 'winner'
        @result = Result.find_by_match_id_and_entry_id(@match.id, entry.id)
        @result.result = params[:winner]
        @result.save
      end
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