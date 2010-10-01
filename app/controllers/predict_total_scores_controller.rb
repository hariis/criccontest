class PredictTotalScoresController < ApplicationController
  layout 'application'
  
  # GET /predict_total_scores
  # GET /predict_total_scores.xml
  def index
    @predict_total_scores = PredictTotalScore.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @predict_total_scores }
    end
  end

  # GET /predict_total_scores/1
  # GET /predict_total_scores/1.xml
  def show
    @predict_total_score = PredictTotalScore.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @predict_total_score }
    end
  end

  # GET /predict_total_scores/new
  # GET /predict_total_scores/new.xml
  def new
    @predict_total_score = PredictTotalScore.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @predict_total_score }
    end
  end

  # GET /predict_total_scores/1/edit
  def edit
    @predict_total_score = PredictTotalScore.find(params[:id])
  end

  # POST /predict_total_scores
  # POST /predict_total_scores.xml
  def create
    @predict_total_score = PredictTotalScore.new(params[:predict_total_score])

    respond_to do |format|
      if @predict_total_score.save
        flash[:notice] = 'PredictTotalScore was successfully created.'
        format.html { redirect_to(@predict_total_score) }
        format.xml  { render :xml => @predict_total_score, :status => :created, :location => @predict_total_score }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @predict_total_score.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /predict_total_scores/1
  # PUT /predict_total_scores/1.xml
  def update
    @predict_total_score = PredictTotalScore.find(params[:id])

    respond_to do |format|
      if @predict_total_score.update_attributes(params[:predict_total_score])
        flash[:notice] = 'PredictTotalScore was successfully updated.'
        format.html { redirect_to(@predict_total_score) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @predict_total_score.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /predict_total_scores/1
  # DELETE /predict_total_scores/1.xml
  def destroy
    @predict_total_score = PredictTotalScore.find(params[:id])
    @predict_total_score.destroy

    respond_to do |format|
      format.html { redirect_to(predict_total_scores_url) }
      format.xml  { head :ok }
    end
  end
end
