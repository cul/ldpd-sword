# frozen_string_literal: true

class Sword::Mets::ProquestEtdXmlDataElement < Sword::Mets::XmlDataElement
  attr_accessor :authors,
                :comp_date,
                :degree,
                :institution_code,
                :institution_contact,
                :institution_name,
                :embargo_code,
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

  def parse_comp_date
    @comp_date = @xml_data.xpath(@xpath_info[:comp_date], @xpath_info[:namespace]).text
  end

  def parse_degree
    @degree = @xml_data.xpath(@xpath_info[:degree], @xpath_info[:namespace]).text
  end

  def parse_embargo_code
    @embargo_code = @xml_data.xpath(@xpath_info[:embargo_code], @xpath_info[:namespace]).text
  end

  def parse_institution_code
    @institution_code = @xml_data.xpath(@xpath_info[:institution_code], @xpath_info[:namespace]).text
  end

  def parse_institution_contact
    @institution_contact = @xml_data.xpath(@xpath_info[:institution_contact], @xpath_info[:namespace]).text
  end

  def parse_institution_name
    @institution_name = @xml_data.xpath(@xpath_info[:institution_name], @xpath_info[:namespace]).text
  end

  def parse_subjects
    @diss_cat_descs = @xml_data.xpath(@xpath_info[:subjects], @xpath_info[:namespace])
    @diss_cat_descs.each do |diss_cat_desc|
      @subjects.push diss_cat_desc.text
    end
  end

  def parse
    super
    parse_authors
    parse_comp_date
    parse_degree
    parse_embargo_code
    parse_institution_code
    parse_institution_contact
    parse_institution_name
    parse_subjects
  end
end
