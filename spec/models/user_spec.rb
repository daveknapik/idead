require 'spec_helper'

describe User do
  describe ".password_required?" do
    it "returns true if the user has no authentications" do
      user = FactoryGirl.build :user
      expect(user.password_required?).to be_true
    end

    it "returns true if the user has a password, whether or not they have authentications" do
      user_with_authentications = FactoryGirl.build :user_with_authentications, password: Faker::Internet.password
      expect(user_with_authentications.password_required?).to be_true

      user_without_authentications = FactoryGirl.build :user, password: Faker::Internet.password
      expect(user_without_authentications.password_required?).to be_true
    end

    it "returns false if the user has authentications but no password" do
      user = FactoryGirl.build :user, password: nil
      user.authentications << FactoryGirl.build(:authentication)

      expect(user.password_required?).to be_false
    end
  end
end
