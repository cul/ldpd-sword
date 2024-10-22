# frozen_string_literal: true

class Sword::Mets::ProquestEtdXmlDataElement < Sword::Mets::XmlDataElement
  attr_accessor :authors,
                :subjects

  def initialize(nokogiri_xml_element, xpath_info)
    super
    @authors = []
    @subjects = []
  end

  def parse_authors
    diss_authors = @xml_data.xpath(@xpath_info[:author_name], @xpath_info[:namespace])
    diss_authors.each do |author|
      person = create_personal_author(author)
      person.role = 'author'
      @authors << person
    end
  end

  def create_personal_author(author)
    person = Sword::Metadata::PersonalName.new
    person.first_name = author.xpath(@xpath_info[:first_name], @xpath_info[:namespace]).text
    person.middle_name = author.xpath(@xpath_info[:middle_name], @xpath_info[:namespace]).text
    person.last_name = author.xpath(@xpath_info[:surname], @xpath_info[:namespace]).text
    person
  end

  def parse_subjects
    @diss_cat_descs = @xml_data.xpath(@xpath_info[:subjects], @xpath_info[:namespace])
    @diss_cat_descs.each do |diss_cat_desc|
      @subjects.push diss_cat_desc.text
    end
  end
end
