class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  has_secure_password
  has_secure_token :auth_token
  
  validates_presence_of :name, :email
  validates_email_format_of :email, :message => 'format is invalid'
  validates_uniqueness_of :email, :auth_token
  
  enum role: [:admin, :user, :guest]
end
