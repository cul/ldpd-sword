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
    # first_author.first_name = 'John'
    # first_author.middle_name = 'Fritz'
    # first_author.first_name = 'Smith'
    result =  deposit.authors.any? do |person|
      person.first_name == 'John'  && person.middle_name == 'Fritz' && person.last_name == 'Smith'
    end
    assert result, 'Author Smith not found'

    result =  deposit.authors.any? do |person|
      person.first_name == 'Jane'  && person.middle_name == 'Freeda' && person.last_name == 'Doe'
    end
    assert result, 'Author Doe not found'
  end
end
