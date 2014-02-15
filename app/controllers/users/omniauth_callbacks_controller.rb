class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    omniauth = request.env["omniauth.auth"] 
    authentication = Authentication.where(provider: omniauth["provider"], uid: omniauth["uid"])

    if authentication.present?
      flash[:notice] = I18n.t("devise.sessions.signed_in")
      sign_in_and_redirect(:user, authentication.first.user)
    elsif current_user.present?
      current_user.authentications.find_or_create_by(provider: omniauth["provider"], 
                                                     uid: omniauth["uid"],
                                                     token: omniauth["credentials"]["token"],
                                                     secret: omniauth["credentials"]["secret"])
      flash[:notice] = I18n.t("devise.omniauth_callbacks.success", kind: "Twitter")
      redirect_to root_url
    else
      session[:omniauth] = omniauth.except('extra')
      redirect_to new_user_registration_url
    end
  end
end