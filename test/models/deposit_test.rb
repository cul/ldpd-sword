require 'test_helper'
class DepositTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @deposit = Deposit.new(title: "Example Deposit",
                           depositor: Depositor.new(name: "Fred"),
                           collection: Collection.new(name: "Cool"))
  end

  test "should be valid" do
    assert @deposit.valid?
  end
end
