require 'rake'
require 'nokogiri'
require 'sword/deposit_utils'
require 'sword/deposit_content'
require 'sword/person'
module Sword
module Parsers
class BmcParser
  
  @@TYPE_OF_CONTENT = 'text'
  # @@GENRE = 'Articles'
  @@GENRE_URI = SWORD_CONFIG[:metadata_values][:genre_uri_bmc]
  # @@LANGUAGE = 'English'
  @@LANGUAGE_URI = SWORD_CONFIG[:metadata_values][:language_uri]
  
  @deposit_content = nil
  @zip_file = nil
  
  attr_accessor :deposit_content 
                
  def parse(temp_dir, zip_file)
    
    @zip_file = zip_file 
    
    @deposit_content = DepositContent.new
    
    parse_content(@deposit_content, temp_dir)
    
    return @deposit_content
  end    
  

  def parse_content(deposit_content, content_dir)  

    deposit_content.type_of_content = @@TYPE_OF_CONTENT
    deposit_content.genre_uri = @@GENRE_URI
    deposit_content.language_uri = @@LANGUAGE_URI
    
    contentFileName = getContentFileName(content_dir) 
    contentXml = Nokogiri::XML(File.read(content_dir + "/" + contentFileName))
    
    deposit_content.title = contentXml.css("art>fm>bibl>title>p").text
    deposit_content.abstract = getAbstract(contentXml)
    
    deposit_content.source = contentXml.css("art>fm>bibl>source").text
    deposit_content.issn = contentXml.css("art>fm>bibl>issn").text
    deposit_content.pubdate = contentXml.css("art>fm>bibl>pubdate").text
    deposit_content.volume = contentXml.css("art>fm>bibl>volume").text
    deposit_content.issue = contentXml.css("art>fm>bibl>issue").text   
    deposit_content.fpage = contentXml.css("art>fm>bibl>fpage").text
    deposit_content.pub_doi = contentXml.css("art>fm>bibl>xrefbib>pubidlist>pubid[@idtype='doi']").text
    
    deposit_content.copyrightNotice = contentXml.css("art>fm>cpyrt>note").text

    deposit_content.authors = getAuthors(contentXml)
    
    deposit_content.attachments = getAttachments(content_dir)
    
    deposit_content.embargo_code = '0'
    
    start_date = DateTime.now
    deposit_content.embargo_start_date = start_date.strftime('%m/%d/%Y')
    
    deposit_content.note = keywords(contentXml)

    return deposit_content
  end  
  
  def keywords(contentXml)
    
    keywords = ''
    contentXml.css("kwdg>kwd").each do |keyword|
      if(keywords == '')
        keywords = keyword.text
      else
        keywords = keywords + ', ' + keyword.text
      end    
    end

    return keywords
  end
  
  def getAllFilesList(content_dir)
    mets = Nokogiri::XML(File.read(content_dir + '/mets.xml'))
    files = []
    mets.css("FLocat[@LOCTYPE='URL']").each do |file_node|
      file = file_node["href"]
      if(file == nil)
        file = file_node["xlink:href"]
      end
      files.push(file)
    end
    return files   
  end
    
    
  def getContentFileName(content_dir)       
    files = getAllFilesList(content_dir)
    return files[0]
  end
   
    
  def getDocsList(content_dir)
    files = getAllFilesList(content_dir)  
    files = files.drop(1)  
    return files
  end   
  
  
  def getAttachments(content_dir)
    
      file_list = FileList.new(content_dir + "/*").exclude('**/mets.xml')

      attachments = []
      
      file_list.each  do | file |
        attachments.push(file)
      end
      
      attachments.push(@zip_file)

      return attachments
  end  
  
  
  def getAuthors(contentXml)
    
    authors = []
    
    contentXml.css("art>fm>bibl>aug>au").each do |author|
      person = Person.new
      person.last_name = author.css("snm").text
      person.first_name = author.css("fnm").text
      person.role = 'author'
      authors.push(person)
    end     
    
    return authors
  end


  def getAbstract(contentXml)

    abstract = ''
    
    contentXml.css("art>fm>abs>sec>sec").each do |sec|
      abstract = getParagraphs(sec, abstract)
    end    
    
    if(abstract == '')
      contentXml.css("art>bdy>sec").each do |sec|
        abstract = getParagraphs(sec, abstract)
      end       
    end  

    return abstract
  end  
  
  def getParagraphs(sec, abstract)
    sec.css("p").each_with_index do |p, index|
      if(index == 0)
        if(!p.text.empty?)
          abstract = abstract + p.text + ": "
        end  
      else
        abstract = abstract + p.text + " "
      end    
    end 
    return abstract
  end
  
end
end
end
