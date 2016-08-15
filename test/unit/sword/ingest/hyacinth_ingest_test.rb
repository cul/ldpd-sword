require 'test_helper'
require 'sword/ingest/hyacinth_ingest'
require 'sword/composers/hyacinth_composer'
require 'sword/deposit_content'

class HyacinthIngestTest < ActiveSupport::TestCase
  setup do
    @deposit_content = Sword::DepositContent.new
    @deposit_content.title = 'Testing the Hyacinth Composer'
    @hyacinth_composer = Sword::Composers::HyacinthComposer.new
    @hyacinth_ingest = Sword::Ingest::HyacinthIngest.new
  end

  test "assert true" do
    result = @hyacinth_composer.compose_json( @deposit_content, 'test-project', 'item')
    # fcd1, 08/15/16: Following makes an actual ingest to running Hyacinth dev server
    # @hyacinth_ingest.ingest_json result
    assert true
    # assert_equal result, '{"project":{"string_key":"test-project"},"title":"Testing the Hyacinth Composer"}'
  end
end
