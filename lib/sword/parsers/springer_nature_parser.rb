require 'rake'
require 'nokogiri'
require 'sword/deposit_utils'
require 'sword/deposit_content'
require 'sword/person'
module Sword
module Parsers
class SpringerNatureParser
  NS = {
    'mets' =>"http://www.loc.gov/METS/",
    'etds' => "http://www.etdadmin.com/ns/etdsword",
    'epdcx'=>"http://purl.org/eprint/epdcx/2006-11-16/"
  }
  DEFAULT_NODE = Nokogiri::XML("<foo></foo>").css("foo").first

  TYPE_OF_CONTENT = 'text'
  GENRE_VALUE = METADATA_VALUES[:genre_value_springer_nature]
  GENRE_URI = METADATA_VALUES[:genre_uri_springer_nature]
  LANGUAGE_VALUE = METADATA_VALUES[:language_value]
  LANGUAGE_URI = METADATA_VALUES[:language_uri]
  PHYSICAL_LOCATION = 'NNC'
  RECORD_CONTENT_SOURCE = 'NNC'

  DC_PURL = 'http://purl.org/dc/elements/1.1/'
  STATEMENT = "epdcx|statement[epdcx|propertyURI='"
  PREFIX_DC_ELEMENTS = "epdcx|statement[epdcx|propertyURI='http://purl.org/dc/elements/1.1/"
  PREFIX_DC_TERMS = "epdcx|statement[epdcx|propertyURI='http://purl.org/dc/terms/"
  PREFIX_EPRINT_TERMS = "epdcx|statement[epdcx|propertyURI='http://purl.org/eprint/terms/"
  POSTFIX = "']>epdcx|valueString"
  POSTFIX_DOI = "']>epdcx|valueString[epdcx|sesURI='http://purl.org/dc/terms/URI']"
  POSTFIX_DATE = "']>epdcx|valueString[epdcx|sesURI='http://purl.org/dc/terms/W3CDTF']"

  @deposit_content = nil

  attr_accessor :deposit_content

  def parse(temp_dir, zip_file)

    @deposit_content = DepositContent.new

    parse_content(temp_dir)

    return @deposit_content
  end

  def findDataFile(directory)
    Dir.glob(directory + "/mets.xml") { | file |
      return file
    }
  end

  def parse_content(content_dir)

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

    @deposit_content.type_of_content = TYPE_OF_CONTENT
    @deposit_content.genre_value = GENRE_VALUE
    @deposit_content.genre_uri = GENRE_URI
    @deposit_content.language_value = LANGUAGE_VALUE
    @deposit_content.language_uri = LANGUAGE_URI
    @deposit_content.title = (contentXml.css("#{PREFIX_DC_ELEMENTS}title#{POSTFIX}").first || DEFAULT_NODE).text
    @deposit_content.abstract = (contentXml.css("#{PREFIX_DC_TERMS}abstract#{POSTFIX}").first || DEFAULT_NODE).text
    @deposit_content.authors = getAuthors(contentXml)
    @deposit_content.pub_doi = (contentXml.css("#{PREFIX_DC_ELEMENTS}identifier#{POSTFIX}").first || DEFAULT_NODE).text
    @deposit_content.dateIssued = (contentXml.css("#{PREFIX_DC_TERMS}available#{POSTFIX}").first || DEFAULT_NODE).text
    @deposit_content.note = getSubjects(contentXml)
    parse_bibliographic_citation contentXml
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

    contentXml.css("#{PREFIX_DC_ELEMENTS}creator#{POSTFIX}").each do |author|
      person = Person.new
      person.full_name_naf_format = author.text
      authors.push(person)
    end

    return authors
  end

  # for now, just insert the subjects into a note field
  def getSubjects(contentXml)

    subjects_string = ''

    contentXml.css("#{PREFIX_DC_ELEMENTS}subject#{POSTFIX}").each do |subject|
      subjects_string << subject << ', '
    end

    return subjects_string.chomp ', '
  end

  def parse_bibliographic_citation contentXml

    bibliographic_citation = (contentXml.css("#{PREFIX_EPRINT_TERMS}bibliographicCitation#{POSTFIX}").first || DEFAULT_NODE).text
    # International Journal of Mental Health Systems. 2016 Jan 04;10(1):1
    # match = /^([ \w]+)\.  (\d\d\d\d)[ \w]+;(\d*)\((\d*):(\d*)/.match foo
    match = /^([ \w]+)\. (\d\d\d\d) \w\w\w \d\d;(\d+)\((\d+)\):(\d*)/.match bibliographic_citation
    # match = /^foo/.match 'fodo'
    unless match.nil?
      @deposit_content.parent_publication_title = match[1]
      @deposit_content.pubdate = match[2]
      @deposit_content.volume = match[3]
      @deposit_content.issue = match[4]
      @deposit_content.fpage = match[5]
    end
  end

end
end
end
