require 'rake'
require 'nokogiri'
require 'sword/deposit_utils'
require 'sword/deposit_content'
require 'sword/person'
module Sword
module Parsers
class TowJournalismParser
  NS = {
    'mets' =>"http://www.loc.gov/METS/",
    'etds' => "http://www.etdadmin.com/ns/etdsword",
    'epdcx'=>"http://purl.org/eprint/epdcx/2006-11-16/"
  }
  DEFAULT_NODE = Nokogiri::XML("<foo></foo>").css("foo").first

  TYPE_OF_CONTENT = 'text'
  GENRE_VALUE = METADATA_VALUES[:genre_value_tow_journalism]
  GENRE_URI = METADATA_VALUES[:genre_uri_tow_journalism]
  LANGUAGE_VALUE = METADATA_VALUES[:language_value]
  LANGUAGE_URI = METADATA_VALUES[:language_uri]
  PHYSICAL_LOCATION = 'NNC'
  RECORD_CONTENT_SOURCE = 'NNC'

  @deposit_content = nil

  attr_accessor :deposit_content

  def parse(temp_dir, zip_file)

    @deposit_content = DepositContent.new

    parse_content(@deposit_content, temp_dir)

    return @deposit_content
  end

  def findDataFile(directory)
      Dir.glob(directory + "/mets.xml") { | file |
        return file
      }
  end

  def parse_content(deposit_content, content_dir)

    dataFile = findDataFile(content_dir)
    contentXml = nil
    open(dataFile) do |b|
      contentXml = b.read
      contentXml.sub!('xmlns="http://www.etdadmin.com/ns/etdsword"', '')
      # substitute CRNL for NL
      contentXml.gsub!(/\x0D(\x0A)?/,0x0A.chr)
      # replace all control characters but NL and TAB
      contentXml.gsub!(/[\x01-\x08]/,'')
      contentXml.gsub!(/[\x0B-\x1F]/,'')
      contentXml = Nokogiri::XML(contentXml)
    end

    deposit_content.type_of_content = TYPE_OF_CONTENT
    # deposit_content.genre = GENRE
    deposit_content.genre_value = GENRE_VALUE
    deposit_content.genre_uri = GENRE_URI
    deposit_content.language_value = LANGUAGE_VALUE
    deposit_content.language_uri = LANGUAGE_URI
    deposit_content.physicalLocation = PHYSICAL_LOCATION
    deposit_content.recordContentSource = RECORD_CONTENT_SOURCE
    deposit_content.title = (contentXml.css("title").first || DEFAULT_NODE).text
    deposit_content.abstract = (contentXml.css("content>abstract").first || DEFAULT_NODE).text
    deposit_content.dateIssued = (contentXml.css("description>dates>date").first || DEFAULT_NODE).text
    deposit_content.corporate_names = getCorporateNames()
    deposit_content.authors = getAuthors(contentXml)

  end

  def getAttachments(content_dir)

      file_list = FileList.new(content_dir + "/*").exclude('**/mets.xml', '**/*DATA.xml')

      attachments = []

      file_list.each  do | file |
        attachments.push(file)
      end

      return attachments
  end

  def getAffiliation(contentXml)

    affiliation = (contentXml.css("DISS_description>DISS_institution>DISS_inst_name").first || DEFAULT_NODE).text
    institutional_contact = (contentXml.css("DISS_description>DISS_institution>DISS_inst_contact").first || DEFAULT_NODE).text

    # fcd1, 04Jan17: Need to handle Teachers College a bit differently
    if institutional_contact.partition(':').first == 'TC'
      affiliation = 'Teachers College' + "." + institutional_contact.partition(':').third
    else
      affiliation = affiliation + ". " + institutional_contact
    end
  end

  def getAuthors(contentXml)

    authors = []

    contentXml.css("authorship>author").each do |author|
      person = Person.new

      person.last_name = author.css("surname").text
      person.first_name = author.css("fname").text
      person.middle_name = author.css("middle").text
      person.affiliation = getAffiliation(contentXml)

      authors.push(person)
    end

    return authors
  end

  def getCorporateNames()
    METADATA_VALUES[:corporate_name_tow_journalism]
  end

end
end
end
