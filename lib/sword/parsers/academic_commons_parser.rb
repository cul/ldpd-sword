require 'rake'
require 'nokogiri'
require 'sword/deposit_utils'
require 'sword/deposit_content'
require 'sword/person'
module Sword
module Parsers
class AcademicCommonsParser
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

    @deposit_content.include_degree_info = false
    # @deposit_content.type_of_resource = TYPE_OF_RESOURCE
    # @deposit_content.genre_value = GENRE_VALUE
    # @deposit_content.genre_uri = GENRE_URI
    # @deposit_content.language_value = LANGUAGE_VALUE
    # @deposit_content.language_uri = LANGUAGE_URI
    # @deposit_content.title = getTitle
    @deposit_content.title = @contentXml.xpath('//mods:title').text
    # @deposit_content.abstract = getAbstract
    @deposit_content.abstract = @contentXml.xpath('//mods:abstract').text
    @deposit_content.authors = getAuthors
    # puts @deposit_content.authors.inspect
    # @deposit_content.pub_doi = getPubDoi
    # @deposit_content.dateIssued = getDateIssued
    @deposit_content.dateIssued = @contentXml.xpath("//mods:originInfo/mods:dateIssued").text
    @deposit_content.note_internal = @contentXml.xpath("//mods:note[@type='internal']").text
    @deposit_content.identifier_doi = @contentXml.xpath("//mods:identifier[@type='doi']").text
    @deposit_content.identifier_uri = @contentXml.xpath("//mods:identifier[@type='uri']").text
  end

  def getAuthors
    authors = []
    @contentXml.xpath('//mods:name').each do |author|
      # @contentXml.xpath('//mods:namePart').each do |author|
      # puts author.inspect
      person = Person.new
      person.full_name_naf_format = author.xpath('./mods:namePart').map{|e| e.text}.join(' ')
      person.uni = author['ID']
      authors.push(person)
    end
    return authors
  end

  # fcd1, 08/06/15:BEGIN>>>>>>
  # New code, to be inserted into the legacy code
  def mods_parse(xmlData_as_nokogiri_xml_element)
    @abstract = xmlData_as_nokogiri_xml_element.xpath('//mods:abstract').text
    @date_issued_start = xmlData_as_nokogiri_xml_element.xpath("//mods:originInfo/mods:dateIssued").text
    @identifier_doi = xmlData_as_nokogiri_xml_element.xpath("//mods:identifier[@type='doi']").text
    @identifier_uri = xmlData_as_nokogiri_xml_element.xpath("//mods:identifier[@type='uri']").text
    @note_internal = xmlData_as_nokogiri_xml_element.xpath("//mods:note[@type='internal']").text
    xmlData_as_nokogiri_xml_element.xpath('//mods:name').each do |mods_name_as_nokogiri_xml_element|
      names << parseModsName(mods_name_as_nokogiri_xml_element)
      @record_info_note = xmlData_as_nokogiri_xml_element.xpath("//mods:recordInfo/mods:recordInfoNote").text
      @title =xmlData_as_nokogiri_xml_element.xpath('//mods:title').text
    end
  end
  def parseModsName nokogiri_xml
    mods_name = Sword::Metadata::ModsName.new
    # currently, if multiple <namePart> are contained with one <name>, the contents
    # of the <nameParts> will be concatenated into one string, in the order in which
    # they are return by the xpath method. For now, this should be an acceptable default
    # behavior since we should only get one ,namePart> per <name>. However, if this is
    # not the case in the future, the code will need to be modified. For exmaple, it can
    # check the value of the 'type' attribute to see if it is set to 'family' or 'given'
    # and act accordingly, for example concatenate as "<family>, <given>"
    mods_name.name_part =
      nokogiri_xml.xpath('./mods:namePart').map{|e| e.text}.join(' ')
    mods_name.id = nokogiri_xml['ID']
    mods_name.type = nokogiri_xml['type']
    # for now, assume just one <role><roleTerm> per <name>
    mods_name.role.role_term = nokogiri_xml.xpath('./mods:role/mods:roleTerm').first.text
    mods_name.role.role_term_type =
      nokogiri_xml.xpath("./mods:role/mods:roleTerm").first['type']
    mods_name.role.role_term_authority =
      nokogiri_xml.xpath("./mods:role/mods:roleTerm").first['authority']
    mods_name.role.role_term_value_uri =
      nokogiri_xml.xpath("./mods:role/mods:roleTerm").first['valueURI']
    mods_name
  end
  # fcd1, 08/06/15:BEGIN>>>>>>
  # New code, to be inserted into the legacy code

  def getAttachments(content_dir)

      file_list = FileList.new(content_dir + "/*").exclude('**/mets.xml', '**/*DATA.xml')

      attachments = []

      file_list.each  do | file |
        attachments.push(file)
      end

      return attachments
  end

  # for now, just insert the subjects into a note field
  def getSubjects

    subjects_string = ''

    @contentXml.css("#{PREFIX_DC_ELEMENTS}subject#{POSTFIX}").each do |subject|
      subjects_string << subject << ', '
    end

    return subjects_string.chomp ', '
  end

  # Abstract value from Springer Nature starts with the word "Abstract", which is
  # redundant. Therefore, it will be removed -- along with preceding white space
  # and following '\n'
  def getAbstract
    abstract_value_first = @contentXml.css("#{PREFIX_DC_TERMS}abstract#{POSTFIX}").first
    return nil if abstract_value_first.nil?
    abstract_value = abstract_value_first.text
    abstract_value.gsub(/^\s*Abstract\n/,'')
  end

  def parse_bibliographic_citation

    bibliographic_citation_first = @contentXml.css("#{PREFIX_EPRINT_TERMS}bibliographicCitation#{POSTFIX}").first
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
    title_first = @contentXml.css("#{PREFIX_DC_ELEMENTS}title#{POSTFIX}").first
    return nil if title_first.nil?
    title_first.text
  end

  def getPubDoi
    pub_doi_url_first = @contentXml.css("#{PREFIX_DC_ELEMENTS}identifier#{POSTFIX}").first
    return nil if pub_doi_url_first.nil?
    pub_doi_url = pub_doi_url_first.text
    # remove url prefix, ugly way to do it
    pub_doi_url.slice!(0,18)
    pub_doi_url
  end

  def getDateIssued
    date_issued_first = @contentXml.css("#{PREFIX_DC_TERMS}available#{POSTFIX}").first
    return nil if date_issued_first.nil?
    # only want the year
    date_issued = date_issued_first.text.slice(0,4)
  end

end
end
end
