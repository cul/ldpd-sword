require 'rake'
require 'nokogiri'
require 'sword/deposit_utils'
require 'sword/deposit_content'
require 'sword/person'
module Sword
module Parsers
class MdpiParser
  TYPE_OF_RESOURCE = 'text'
  GENRE_VALUE = METADATA_VALUES[:genre_value_springer_nature]
  GENRE_URI = METADATA_VALUES[:genre_uri_springer_nature]
  LANGUAGE_VALUE = METADATA_VALUES[:language_value]
  LANGUAGE_URI = METADATA_VALUES[:language_uri]

  DC_PURL = 'http://purl.org/dc/elements/1.1/'
  STATEMENT = "epdcx|statement[epdcx|propertyURI='"
  PREFIX_DC_ELEMENTS = "epdcx|statement[epdcx|propertyURI='http://purl.org/dc/elements/1.1/"
  PREFIX_DC_TERMS = "epdcx|statement[epdcx|propertyURI='http://purl.org/dc/terms/"
  PREFIX_EPRINT_TERMS = "epdcx|statement[epdcx|propertyURI='http://purl.org/eprint/terms/"
  POSTFIX = "']>epdcx|valueString"
  POSTFIX_DOI = "']>epdcx|valueString[epdcx|sesURI='http://purl.org/dc/terms/URI']"
  POSTFIX_DATE = "']>epdcx|valueString[epdcx|sesURI='http://purl.org/dc/terms/W3CDTF']"
  NAMESPACE_HASH = {'epdcx' => 'http://purl.org/eprint/epdcx/2006-11-16/'}

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
    open(dataFile) do |b|
      @contentXml = b.read
      @contentXml.sub!('xmlns="http://www.etdadmin.com/ns/etdsword"', '')
      # substitute CRNL for NL
      @contentXml.gsub!(/\x0D(\x0A)?/,0x0A.chr)
      # replace all control characters but NL and TAB
      @contentXml.gsub!(/[\x01-\x08]/,'')
      @contentXml.gsub!(/[\x0B-\x1F]/,'')
      @contentXml = Nokogiri::XML @contentXml
    end

    @deposit_content.type_of_resource = TYPE_OF_RESOURCE
    @deposit_content.genre_value = GENRE_VALUE
    @deposit_content.genre_uri = GENRE_URI
    @deposit_content.language_value = LANGUAGE_VALUE
    @deposit_content.language_uri = LANGUAGE_URI
    @deposit_content.title = getTitle
    @deposit_content.abstract = getAbstract
    @deposit_content.authors = getAuthors
    @deposit_content.pub_doi = getPubDoi
    @deposit_content.dateIssued = getDateIssued
    @deposit_content.note = getSubjects

    parse_bibliographic_citation
  end

  def getAttachments(content_dir)

      file_list = FileList.new(content_dir + "/*").exclude('**/mets.xml', '**/*DATA.xml')

      attachments = []

      file_list.each  do | file |
        attachments.push(file)
      end

      return attachments
  end

  def getAuthors

    authors = []

    @contentXml.css("#{PREFIX_DC_ELEMENTS}creator#{POSTFIX}",
                    NAMESPACE_HASH).each do |author|
      person = Person.new
      person.full_name_naf_format = author.text
      authors.push(person)
    end

    return authors
  end

  # for now, just insert the subjects into a note field
  def getSubjects

    subjects_string = ''

    @contentXml.css("#{PREFIX_DC_ELEMENTS}subject#{POSTFIX}",
                    NAMESPACE_HASH).each do |subject|
      subjects_string << subject << ', '
    end

    return subjects_string.chomp ', '
  end

  # Abstract value from Springer Nature starts with the word "Abstract", which is
  # redundant. Therefore, it will be removed -- along with preceding white space
  # and following '\n'
  def getAbstract
    abstract_value_first = @contentXml.css("#{PREFIX_DC_TERMS}abstract#{POSTFIX}",
                                           NAMESPACE_HASH).first
    return nil if abstract_value_first.nil?
    abstract_value = abstract_value_first.text
    abstract_value.gsub(/^\s*Abstract\n/,'')
  end

  def parse_bibliographic_citation

    bibliographic_citation_first = @contentXml.css("#{PREFIX_EPRINT_TERMS}bibliographicCitation#{POSTFIX}",
                                                   NAMESPACE_HASH).first
    return nil if bibliographic_citation_first.nil?
    bibliographic_citation = bibliographic_citation_first.text
    # Here is an example of an entry from an actual mets.xml
    # International Journal of Mental Health Systems. 2016 Jan 04;10(1):1
    match = /^([ \w]+)\. (\d\d\d\d) \w\w\w \d\d;(\d+)\((\d+)\):(\d*)/.match bibliographic_citation
    unless match.nil?
      @deposit_content.parent_publication_title = match[1]
      @deposit_content.pubdate = match[2]
      @deposit_content.volume = match[3]
      @deposit_content.issue = match[4]
      @deposit_content.fpage = match[5]
    end
  end

  def getTitle
    title_first = @contentXml.css("#{PREFIX_DC_ELEMENTS}title#{POSTFIX}",
                                  NAMESPACE_HASH).first
    return nil if title_first.nil?
    title_first.text
  end

  def getPubDoi
    pub_doi_url_first = @contentXml.css("#{PREFIX_DC_ELEMENTS}identifier#{POSTFIX}",
                                        NAMESPACE_HASH).first
    return nil if pub_doi_url_first.nil?
    pub_doi_url = pub_doi_url_first.text
    # remove url prefix, ugly way to do it
    pub_doi_url.slice!(0,18)
    pub_doi_url
  end

  def getDateIssued
    date_issued_first = @contentXml.css("#{PREFIX_DC_TERMS}available#{POSTFIX}", NAMESPACE_HASH).first
    return nil if date_issued_first.nil?
    # only want the year
    date_issued = date_issued_first.text.slice(0,4)
  end

end
end
end
