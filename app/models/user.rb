class User < ApplicationRecord
  validates :name, :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
end
