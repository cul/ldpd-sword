class Deposit < ApplicationRecord
  # belongs_to :depositor
  # belongs_to :collectio
  serialize :deposit_errors, type: Array
  serialize :deposit_files, type: Array
end
