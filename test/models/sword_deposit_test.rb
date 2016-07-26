require 'test_helper'
# NEED TO GET FIXTURES TO WORK
class SwordDepositTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @sword_deposit = SwordDeposit.new(title: "Example Sword Deposit",
                                      depositor: Depositor.new(name: "Fred"),
                                      collection: Collection.new(name: "Cool"))
    # @sword_deposit.depositor = Depositor.new(name: "Fred")
    # @sword_deposit.collection = Collection.new(name: "Cool")
  end

  test "should be valid" do
    assert @sword_deposit.valid?
  end
end
