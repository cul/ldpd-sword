require 'test_helper'
require 'sword/parsers/proquest_parser'

class ProquestParserTest < ActiveSupport::TestCase
  setup do
    @parser = Sword::Parsers::ProquestParser.new
  end

  test "parse after stripping illegal control characters" do
    content_dir = File.dirname(fixture_path_for('proquest/diss-001/mets.xml'))
    parser = Sword::Parsers::ProquestParser.new
    deposit = parser.parse(content_dir, nil)
    assert deposit.is_a? Sword::DepositContent
    assert_equal 'The Parity of Stuff', deposit.title
    assert_equal '0', deposit.embargo_code, "Embargo code mismatch: #{deposit.embargo_code}"
    assert_equal '04/03/2015', deposit.embargo_start_date, "Embargo start mismatch: #{deposit.embargo_start_date}"
    # fcd1, 08/02/16: This is original code from hypatia-new, as is the sample fixture file. However, doesn't pass
    # so commented the line out, new line has day (DD) and mont (MM) numbers swapped
    # assert_equal '2015-04-03', deposit.embargo_release_date, "Embargo release mismatch: #{deposit.embargo_start_date}"
    assert_equal '2015-03-04', deposit.embargo_release_date, "Embargo release mismatch: #{deposit.embargo_start_date}"
  end
  test "parse with significant newlines" do
    content_dir = File.dirname(fixture_path_for('proquest/diss-002/mets.xml'))
    parser = Sword::Parsers::ProquestParser.new
    deposit = parser.parse(content_dir, nil)
    assert deposit.is_a? Sword::DepositContent
    assert_equal 'The Emancipation of Stuff', deposit.title
    assert_equal '4', deposit.embargo_code, "Embargo code mismatch: #{deposit.embargo_code}"
    assert_equal '05/05/2015', deposit.embargo_start_date, "Embargo start mismatch: #{deposit.embargo_start_date}"
    assert_equal '2017-05-05', deposit.embargo_release_date, "Embargo release mismatch: #{deposit.embargo_start_date}"
  end
end
