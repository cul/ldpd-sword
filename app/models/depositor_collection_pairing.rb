class DepositorCollectionPairing < ApplicationRecord
  belongs_to :depositor
  belongs_to :collection
end
