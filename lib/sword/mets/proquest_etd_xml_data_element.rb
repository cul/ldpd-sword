# frozen_string_literal: true

class Sword::Mets::ProquestEtdXmlDataElement < Sword::Mets::XmlDataElement
  include Sword::Mets::ProquestConstants

  def initialize(nokogiri_xml_element, xpath_info = Sword::Mets::ProquestConstants::XPATH_INFO)
    super
    @authors = nil
    @subjects = nil
  end

  # Override
  def authors
    @authors ||= begin
      diss_authors = @xml_data.xpath(@xpath_info[:author_name], @xpath_info[:namespace])
      diss_authors.map { |author| create_personal_name(author, role: 'author') }
    end
  end

  def advisors
    @advisors ||= begin
      diss_advisors = @xml_data.xpath(@xpath_info[:advisor_name], @xpath_info[:namespace])
      diss_advisors.map { |author| create_personal_name(author, role: 'advisor') }
    end
  end

  # Override
  def subjects
    @subjects ||= begin
      @diss_cat_descs = @xml_data.xpath(@xpath_info[:subjects], @xpath_info[:namespace])
      @diss_cat_descs.map(&:text)
    end
  end

  private

  def create_personal_name(author, **other_attrs)
    author_attrs = other_attrs.merge({
      first_name: author.xpath(@xpath_info[:first_name], @xpath_info[:namespace]).text,
      middle_name: author.xpath(@xpath_info[:middle_name], @xpath_info[:namespace]).text,
      last_name: author.xpath(@xpath_info[:surname], @xpath_info[:namespace]).text
    })
    Sword::Metadata::PersonalName.new(**author_attrs)
  end
end
