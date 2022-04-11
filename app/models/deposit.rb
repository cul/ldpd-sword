class Deposit < ApplicationRecord
  # belongs_to :depositor
  # belongs_to :collectio
  serialize :deposit_errors, Array
  serialize :deposit_files, Array
end
