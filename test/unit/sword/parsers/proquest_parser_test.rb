require 'test_helper'

class ProquestParserTest < ActiveSupport::TestCase
  context "Sample mets files" do
    setup do
      @parser = Deposits::ProquestParser.new
    end

    should "parse after stripping illegal control characters" do
      content_dir = File.dirname(fixture_path_for('proquest/diss-001/mets.xml'))
      parser = Deposits::ProquestParser.new
      deposit = parser.parse(content_dir, nil)
      assert deposit.is_a? Deposits::DepositContent
      assert_equal 'The Parity of Analytic Ranks among Quadratic Twists of Elliptic Curves over Number Fields', deposit.title
      assert_equal '0', deposit.embargo_code, "Embargo code mismatch: #{deposit.embargo_code}"
      assert_equal '04/03/2015', deposit.embargo_start_date, "Embargo start mismatch: #{deposit.embargo_start_date}"
      assert_equal '2015-04-03', deposit.embargo_release_date, "Embargo release mismatch: #{deposit.embargo_start_date}"
    end
    should "parse with significant newlines" do
      content_dir = File.dirname(fixture_path_for('proquest/diss-002/mets.xml'))
      parser = Deposits::ProquestParser.new
      deposit = parser.parse(content_dir, nil)
      assert deposit.is_a? Deposits::DepositContent
      assert_equal 'The Emancipation of Memory: Arnold Schoenberg and the Creation of \'A Survivor from Warsaw\'', deposit.title
      assert_equal '4', deposit.embargo_code, "Embargo code mismatch: #{deposit.embargo_code}"
      assert_equal '05/05/2015', deposit.embargo_start_date, "Embargo start mismatch: #{deposit.embargo_start_date}"
      assert_equal '2017-05-05', deposit.embargo_release_date, "Embargo release mismatch: #{deposit.embargo_start_date}"
    end
  end
end