require 'test_helper'

class DepositorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  setup do
    @first_depositor = depositors(:first_depositor)
    @first_collection = collections(:first_collection)
    @second_collection = collections(:second_collection)
  end
    
  test "add a collection to depositor via permissions" do
    assert_difference '@first_depositor.collections.count' do
      @first_depositor.collections << @first_collection
    end
  end
end
