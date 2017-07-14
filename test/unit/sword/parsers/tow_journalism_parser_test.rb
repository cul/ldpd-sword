require 'test_helper'
require 'sword/parsers/tow_journalism_parser'

class TowJournalismParserTest < ActiveSupport::TestCase
  setup do
    @parser = Sword::Parsers::TowJournalismParser.new
  end

  test "parse correctly" do
    content_dir = File.dirname(fixture_path_for('tow_journalism/mets.xml'))
    parser = Sword::Parsers::TowJournalismParser.new
    deposit = parser.parse(content_dir, nil)
    assert deposit.is_a? Sword::DepositContent
    assert_equal 'Tow Journalism: The Title That Was', deposit.title
    first_author = Sword::Person.new
    result =  deposit.authors.any? do |person|
      person.first_name == 'Hermione'  && person.middle_name == 'Jean' && person.last_name == 'Granger'
    end
    assert result, 'Author Granger not found'

    result =  deposit.authors.any? do |person|
      person.first_name == 'Harry'  && person.middle_name == 'James' && person.last_name == 'Potter'
    end
    assert result, 'Author Potter not found'
  end
end
