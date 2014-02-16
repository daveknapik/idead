require 'spec_helper'
include Warden::Test::Helpers

feature "Login" do
  before do
    Warden.test_mode!
  end

  after do
    Warden.test_reset! 
  end

  context "user is not logged in" do
    before do
      logout(:user)
    end

    scenario "sign in and register links are visible" do
      VCR.use_cassette("trends") do
        visit root_url
      end

      expect(page).to have_link "Sign in"
      expect(page).to have_link "Register"
    end

    scenario "sign out link is not visible" do
      VCR.use_cassette("trends") do
        visit root_url
      end

      expect(page).to have_no_link "Sign out"
    end
  end
end