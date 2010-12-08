class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:destroy]
  def new
    @user_session = UserSession.new
    @user_session.email = flash[:email]
  end

  def create
    if params[:user_session][:email].empty?      
      @user_session = UserSession.new
      @user_session.errors.add(:email,"blank :(")
      render :new and return
    end

    @user = User.find_by_email(params[:user_session][:email])

    if !@user.nil?
        if @user.member?
            if @user.activated?
                @user_session = UserSession.new(params[:user_session], true)
                if @user_session.save
                  #flash[:notice] = "Welcome #{@user.display_name}! "
                  if @user.posts.size > 0
                      url_path = @user.posts.find(:first, :order => 'updated_at desc').get_url_for(@user, 'show')
                      redirect_back_or_default(url_path) #posts_url
                  else
                      redirect_back_or_default(contests_url) #posts_url
                  end
                else
                  render :action => 'new'
                end
            else
                flash[:error] = "Your account is not activated. Please activate your account"
                redirect_to contests_url
            end
        else
          #How can this happen? logged in but not a member - Hacked in, perhaps
          flash[:error] = "We're sorry, but we could not locate your account.<br/> Please check the address and try again."
          redirect_to contests_url
        end
    else
      flash[:error] = "We're sorry, but we could not locate your account. Please check the address and try again."
      #redirect_to contests_url
      redirect_to login_path
    end
  end
   
  def destroy  
    @user_session = UserSession.find  
    @user_session.destroy  
    #flash[:notice] = "Successfully logged out."
    #logger.info 'Signing off'
    redirect_to root_url
  end  
  def method_missing(methodname, *args)
       @methodname = methodname
       @args = args
       if methodname == :controller
         controller = 'posts'
       else
         render 'posts/404', :status => 404, :layout => false
       end
   end
end
