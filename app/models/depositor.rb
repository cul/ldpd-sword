class Depositor < ApplicationRecord
  has_secure_password
  has_many :deposits
  has_many :depositor_collection_pairings, dependent: :destroy
  has_many :collections, through: :depositor_collection_pairings

  def Depositor.create_password_digest password
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(password, cost: cost)
  end
end
