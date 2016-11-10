class Deposit < ActiveRecord::Base
  belongs_to :depositor
  belongs_to :collection
  serialize :deposit_errors, Array
  serialize :deposit_files, Array
end
