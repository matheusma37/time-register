require 'rails_helper'

RSpec.describe TimeLog, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    let(:user) { create(:user) }

    it "is valid with valid attributes" do
      time_log = build(:time_log, user: user, clock_in: Time.current)

      expect(time_log).to be_valid
    end

    it "is invalid without a clock_in" do
      time_log = build(:time_log, user: user, clock_in: nil)

      expect(time_log).not_to be_valid
      expect(time_log.errors[:clock_in]).to include("can't be blank")
    end

    context "when user already has an open time log" do
      it "is invalid if creating another open log" do
        create(:time_log, user: user, clock_in: 1.hour.ago, clock_out: nil)
        new_time_log = build(:time_log, user: user, clock_in: Time.current, clock_out: nil)

        expect(new_time_log).not_to be_valid
        expect(new_time_log.errors[:base]).to include("User already has an open time log")
      end

      it "is valid if the new log has a clock_out" do
        create(:time_log, user: user, clock_in: 1.hour.ago, clock_out: nil)
        new_time_log = build(:time_log, user: user, clock_in: Time.current, clock_out: Time.current + 8.hours)

        expect(new_time_log).to be_valid
      end

      it "ignores itself when updating an existing open log" do
        time_log = create(:time_log, user: user, clock_in: 1.hour.ago, clock_out: nil)
        time_log.clock_in = 2.hours.ago

        expect(time_log).to be_valid
      end
    end

    context "when validating clock_out relative to clock_in" do
      it "is invalid if clock_out is equal to clock_in" do
        time = Time.current
        time_log = build(:time_log, user: user, clock_in: time, clock_out: time)

        expect(time_log).not_to be_valid
        expect(time_log.errors[:clock_out]).to include("must be after clock_in")
      end

      it "is invalid if clock_out is before clock_in" do
        time = Time.current
        time_log = build(:time_log, user: user, clock_in: time, clock_out: time - 1.hour)

        expect(time_log).not_to be_valid
        expect(time_log.errors[:clock_out]).to include("must be after clock_in")
      end

      it "is valid if clock_out is after clock_in" do
        time = Time.current
        time_log = build(:time_log, user: user, clock_in: time, clock_out: time + 1.hour)

        expect(time_log).to be_valid
      end
    end
  end
end
