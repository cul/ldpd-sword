class Deposit < ActiveRecord::Base
  belongs_to :depositor
  belongs_to :collection
end
