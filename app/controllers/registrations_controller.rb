class RegistrationsController < Devise::RegistrationsController
  def create
    super
    session[:omniauth] = nil unless @user.new_record? 
  end

  private

  def build_resource(*args)
    super
    if session[:omniauth]
      @user.name = session[:omniauth]["info"]["name"]
      
      @user.authentications.build(provider: session[:omniauth]["provider"], 
                                  uid: session[:omniauth]["uid"],
                                  token: session[:omniauth]["credentials"]["token"],
                                  secret: session[:omniauth]["credentials"]["secret"])

      @user.valid? #makes validation errors available to registration views
    end
  end
end
