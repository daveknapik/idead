require 'spec_helper'

describe Users::OmniauthCallbacksController do
  let(:authentication) { FactoryGirl.build :twitter_authentication }
  
  before do 
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
      provider: authentication.provider,
      uid: authentication.uid,
      credentials: {
        token: authentication.token,
        secret: authentication.secret
      },
      extra: {
        raw_info: {
          name: Faker::Name.name
        }
      }
    })

    request.env["devise.mapping"] = Devise.mappings[:user] 
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter] 
  end

  describe ".twitter" do
    context "authentication already exists" do
      let(:authentication) { FactoryGirl.create :twitter_authentication, :with_user }

      it "sets the flash[:notice] message to the devise.session.signed_in value" do
        get :twitter
        expect(flash[:notice]).to eq I18n.t("devise.sessions.signed_in")
      end

      it "redirects to the root url" do
        get :twitter
        expect(response).to redirect_to root_url
      end
    end

    context "authentication does not exist, but current user is present" do
      let(:user) { FactoryGirl.create :user }

      before do
        sign_in user 
      end

      it "sets the flash[:notice] message to devise.omniauth_callbacks.success for Twitter" do
        get :twitter
        expect(flash[:notice]).to eq I18n.t("devise.omniauth_callbacks.success", kind: "Twitter")
      end

      it "redirects to the root url" do
        get :twitter
        expect(response).to redirect_to root_url
      end

      it "creates an Authentication for the current_user based on the omniauth info" do
        get :twitter
        expect(user.authentications.first.provider).to eq authentication.provider
        expect(user.authentications.first.uid).to eq authentication.uid
        expect(user.authentications.first.token).to eq authentication.token
        expect(user.authentications.first.secret).to eq authentication.secret
      end
    end

    context "neither authentication nor current_user exists" do
      it "sets session[:omniauth] to the omniauth hash minus its extra key" do
        get :twitter
        expect(session[:omniauth]).to eq OmniAuth.config.mock_auth[:twitter].except("extra")
      end

      it "redirects to the new user registration url" do
        get :twitter
        expect(response).to redirect_to new_user_registration_url
      end
    end
  end
end