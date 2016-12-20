require 'rake'
require 'nokogiri'
require 'sword/deposit_utils'
require 'sword/deposit_content'
require 'sword/person'
module Sword
module Parsers
class ProquestParser
  NS = {
    'mets' =>"http://www.loc.gov/METS/",
    'etds' => "http://www.etdadmin.com/ns/etdsword",
    'epdcx'=>"http://purl.org/eprint/epdcx/2006-11-16/"
  }
  DEFAULT_NODE = Nokogiri::XML("<foo></foo>").css("foo").first

  TYPE_OF_CONTENT = 'text'
  # GENRE = 'Dissertations'
  GENRE_VALUE = SWORD_CONFIG[:metadata_values][:genre_value_proquest]
  GENRE_URI = SWORD_CONFIG[:metadata_values][:genre_uri_proquest]
  # LANGUAGE = 'English'
  LANGUAGE_VALUE = SWORD_CONFIG[:metadata_values][:language_value]
  LANGUAGE_URI = SWORD_CONFIG[:metadata_values][:language_uri]
  PHYSICAL_LOCATION = 'NNC'
  RECORD_CONTENT_SOURCE = 'NNC'
  LANGUAGE_OF_CATALOGING = 'eng'
  DEGREE = 'Ph.D.'
  DEGREE_GRANTOR = 'Columbia University'
  CORPORATE_ROLE = 'originator'
  ADVISOR_ROLE = 'thesis advisor'
  AUTHOR_ROLE = 'author'
  
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
    deposit_content.languageOfCataloging = LANGUAGE_OF_CATALOGING
    deposit_content.title = (contentXml.css("DISS_title").first || DEFAULT_NODE).text
    deposit_content.abstract = (contentXml.css("DISS_content>DISS_abstract").first || DEFAULT_NODE).text
    deposit_content.subjects = getSubjects(contentXml)
    deposit_content.dateIssued = (contentXml.css("DISS_description>DISS_dates>DISS_comp_date").first || DEFAULT_NODE).text
    deposit_content.corporate_name = getAffiliation(contentXml)
    deposit_content.corporate_role = CORPORATE_ROLE
    
    deposit_content.authors = getAuthors(contentXml)
    deposit_content.advisors = getAdvisors(contentXml)
    deposit_content.attachments = getAttachments(content_dir)
    deposit_content.embargo_code = (contentXml.css("DISS_submission").first || DEFAULT_NODE)["embargo_code"]
    if contentXml.at_css("DISS_authorship>DISS_author>DISS_contact>DISS_contact_effdt")
      deposit_content.embargo_start_date = contentXml.css("DISS_authorship>DISS_author>DISS_contact>DISS_contact_effdt").first.text
    end
    if contentXml.at_css("DISS_restriction>DISS_sales_restriction")
      deposit_content.sales_restriction_date = (contentXml.css("DISS_restriction>DISS_sales_restriction").first || DEFAULT_NODE)["remove"].to_s
    end
    
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
    affiliation = affiliation + ". " + institutional_contact
  end  
  
  def getAdvisors(contentXml)
    
    advisors = []
    
    contentXml.css("DISS_description>DISS_advisor").each do |advisor|
      
      person = Person.new
      
      person.last_name = advisor.css("DISS_surname").text
      person.first_name = advisor.css("DISS_fname").text
      person.middle_name = advisor.css("DISS_middle").text
      person.affiliation = getAffiliation(contentXml)
      person.role = ADVISOR_ROLE
      
      advisors.push(person)
    end     
    
    return advisors
  end    
 
  def getAuthors(contentXml)
    
    authors = []
    
    contentXml.css("DISS_authorship>DISS_author").each do |author|
      person = Person.new
      
      person.last_name = author.css("DISS_surname").text
      person.first_name = author.css("DISS_fname").text
      person.middle_name = author.css("DISS_middle").text
      person.affiliation = getAffiliation(contentXml)
      person.role = AUTHOR_ROLE 
      person.degree = DEGREE
      person.degree_grantor = DEGREE_GRANTOR
      
      authors.push(person)
    end     
    
    return authors
  end   
 
  def getSubjects(contentXml)
     
    subjects = []
    
    contentXml.css("DISS_description>DISS_categorization>DISS_category").each do |category|
      subjects.push(category.css("DISS_cat_desc").text)
    end     
    
    return subjects
  end  
  

end
end
end
