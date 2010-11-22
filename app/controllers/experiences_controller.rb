class ExperiencesController < ApplicationController

 before_filter :load_user

 def load_user
   @user = User.find_by_id(params[:user_id]) if params[:user_id]
 end
   
 def capture_experience
    respond_to do |format|
        format.html
        #format.xml { render :xml => @post }
        format.js { render_to_facebox }
    end
 end
 
 def store_experience
     render :update do |page|    
       if params[:feedback_type].to_i == 0
           page.replace_html "feedback-status", "Please select a feedback type"
       elsif params[:description] == "Let us know what you think!" || params[:description] == ""
           page.replace_html "feedback-status", "Please add some details and share again"  
       else
           experience = Experience.new
           #experience.feedback_type = params[:feedback_type]
           experience.feedback_type = Experience::COMMENT_TYPES.index(params[:feedback_type].to_i) if params[:feedback_type]
           experience.description = params[:description]
           Notifier.deliver_send_experience(experience, @user)
           #page.hide 'facebox'
           page.visual_effect :blind_up, 'facebox'
           #flash[:notice] = "Thank you very much for sharing your feedback. Your effort is highly appreciated"
       end
     end
 end
end
