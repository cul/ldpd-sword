require 'rails_helper'

require 'sword/parsers/mets_parser.rb'

RSpec.describe Sword::Parsers::MetsParser do
  context "API/interface" do
    it 'has #parse method that takes file to parse' do
      expect(subject).to respond_to(:parse).with(1).arguments
    end

    it 'has #flocat_xlink_href attr_reader' do
      expect(subject).to respond_to(:flocat_xlink_href)
    end

    it 'has #agent_name attr_reader' do
      expect(subject).to respond_to(:agent_name)
    end

    it 'has #xmlData_as_nokogiri_xml_element attr_reader' do
      expect(subject).to respond_to(:xmlData_as_nokogiri_xml_element)
    end
  end

  context "In mets file containing expected elements" do

    mets_file = Rails.root.join "spec/fixtures/mets_files/mets_with_expected_elements.xml"
    mets_parser = Sword::Parsers::MetsParser.new
    mets_parser.parse(mets_file)

    it "parses FLocat entries correctly" do
      expect(mets_parser.flocat_xlink_href).to include("research_data/Zoroaster_columbia_0054D_14600.dat",
                                                       "Zarathustra_columbia_0054D_14724.pdf",
                                                       "Zoroaster_columbia_0054D_14600.pdf")
    end

    it "parses agent name correctly" do
      expect(mets_parser.agent_name).to eq "Academic Commons, Columbia University"
    end

    it "parses xmlData correctly as a Nokigiri::Xml::Element with name xmlData" do
      expect(mets_parser.xmlData_as_nokogiri_xml_element.first).to be_instance_of(Nokogiri::XML::Element)
      expect(mets_parser.xmlData_as_nokogiri_xml_element.first.name).to eq('xmlData')
    end
  end

  context "In mets file containing only the <mets> element" do

    mets_file = Rails.root.join "spec/fixtures/mets_files/empty_mets.xml"
    mets_parser = Sword::Parsers::MetsParser.new
    mets_parser.parse(mets_file)

    it "it handles the absence of FLocat element(s) correctly" do
      expect(mets_parser.flocat_xlink_href).to be_empty
    end

    it "it handles the absence of <agent><name> element correctly" do
      expect(mets_parser.agent_name).to be_nil
    end
  end

  context "In Proquest mets file containing only xmlData elements" do

    mets_file = Rails.root.join "spec/fixtures/mets_files/proquest_etd_mets_actual_mets_file.xml"
    mets_parser = Sword::Parsers::MetsParser.new
    mets_parser.parse(mets_file)

    it "parses first xmlData element correctly as a Nokigiri::Xml::Element with name xmlData" do
      expect(mets_parser.xmlData_as_nokogiri_xml_element.first).to be_instance_of(Nokogiri::XML::Element)
      expect(mets_parser.xmlData_as_nokogiri_xml_element.first.name).to eq('xmlData')
    end

    it "parses second xmlData element correctly as a Nokigiri::Xml::Element with name xmlData" do
      expect(mets_parser.xmlData_as_nokogiri_xml_element.second).to be_instance_of(Nokogiri::XML::Element)
      expect(mets_parser.xmlData_as_nokogiri_xml_element.second.name).to eq('xmlData')
    end
  end
end
