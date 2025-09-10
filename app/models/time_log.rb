class TimeLog < ApplicationRecord
  validates :clock_in, presence: true
  validate :unique_null_clock_out_by_user, if: -> { clock_out.nil? }
  validate :clock_out_after_clock_in, if: -> { clock_out.present? }

  belongs_to :user

  private

  def unique_null_clock_out_by_user
    if TimeLog.where(user: user, clock_out: nil).where.not(id: id).exists?
      errors.add(:base, "User already has an open time log")
    end
  end

  def clock_out_after_clock_in
    errors.add(:clock_out, "must be after clock_in") if clock_out <= clock_in
  end
end
