require 'test_helper'

class CollectionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @collection = Collection.new(name: "Example Collection",
                                 atom_title: "Atom Title of Example Collection",
                                 slug: "example-collection")
  end

  test "should be valid" do
    assert @collection.valid?
  end
end
