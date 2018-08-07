require 'test_helper'
require 'sword/parsers/springer_nature_parser'

class AcademicCommmonsParserTest < ActiveSupport::TestCase
  setup do
    @parser = Sword::Parsers::AcademicCommonsParser.new
  end

  test "parse correctly" do
    content_dir = File.dirname(fixture_path_for('academic_commons/mets.xml'))
    parser = Sword::Parsers::AcademicCommonsParser.new
    deposit = parser.parse(content_dir, nil)
    assert deposit.is_a? Sword::DepositContent
    assert_equal 'Test Deposit', deposit.title
    assert_equal 'Abstract blah blah blah', deposit.abstract
    assert_equal '2018', deposit.dateIssued
    assert_equal 'This is the best deposit ever, just FYI', deposit.note_internal
    # assert_equal 'International Journal of Stuff', deposit.parent_publication_title
    # assert_equal '2016', deposit.pubdate
    # assert_equal '10', deposit.volume
    # assert_equal '11', deposit.issue
    # assert_equal '78', deposit.fpage
    puts deposit.authors.inspect

    result =  deposit.authors.any? do |person|
      person.full_name_naf_format == 'User, Test'
    end
    assert result, 'Author "User, Test" not found'

    result =  deposit.authors.any? do |person|
      person.full_name_naf_format == 'Smith, John'
    end
    assert result, 'Author "Smith, John" not found'

    result =  deposit.authors.any? do |person|
      person.full_name_naf_format == 'Galarza, Carla'
    end
    assert result, 'Author "Galarza, Carla" not found'
  end

  test "handle missing info" do
    content_dir = File.dirname(fixture_path_for('springer_nature_missing_info/mets.xml'))
    parser = Sword::Parsers::SpringerNatureParser.new
    deposit = parser.parse(content_dir, nil)
  end
end
