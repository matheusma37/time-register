require "rails_helper"

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:time_logs) }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      user = build(:user)

      expect(user).to be_valid
    end

    it "is invalid without a name" do
      user = build(:user, name: nil)

      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it "is invalid without an email" do
      user = build(:user, email: nil)

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "is invalid with an incorrect email format" do
      user = build(:user, email: "invalid_email")

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("is invalid")
    end

    it "does not allow duplicate emails" do
      create(:user, email: "test@example.com")

      user = build(:user, email: "test@example.com")

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it "does not allow duplicate emails with different letter cases" do
      create(:user, email: "test@example.com")

      user = build(:user, email: "TEST@example.com")

      expect(user).not_to be_valid
    end
  end
end
