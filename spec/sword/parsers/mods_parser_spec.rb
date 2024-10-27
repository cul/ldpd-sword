require 'rails_helper'

require 'sword/parsers/mods_parser.rb'

RSpec.describe Sword::Parsers::ModsParser do
  ########################################## Initial state
  describe 'Initial state' do
    context '#initialize sets @names to' do
      modsParser = Sword::Parsers::ModsParser.new
      it 'an empty array' do
        # expect(described_class.new.names).to be_an_instance_of(Array)
        expect(modsParser.names).to be_an_instance_of(Array)
        expect(modsParser.names.empty?).to be(true)
      end
    end
  end

  ########################################## API/interface
  describe 'API/interface' do
    context 'has attr_accessor for instance var' do
      it 'access_condition_use_and_reproduction_license' do
        expect(subject).to respond_to(:access_condition_use_and_reproduction_license_uri)
        expect(subject).to respond_to(:access_condition_use_and_reproduction_license_uri=)
      end

      it 'access_condition_use_and_reproduction_rights' do
        expect(subject).to respond_to(:access_condition_use_and_reproduction_rights_status_uri)
        expect(subject).to respond_to(:access_condition_use_and_reproduction_rights_status_uri=)
      end

      it 'abstract' do
        expect(subject).to respond_to(:abstract)
        expect(subject).to respond_to(:abstract=)
      end

      it 'date_issued_start' do
        expect(subject).to respond_to(:date_issued_start)
        expect(subject).to respond_to(:date_issued_start=)
      end

      it 'identifier_doi' do
        expect(subject).to respond_to(:identifier_doi)
        expect(subject).to respond_to(:identifier_doi=)
      end

      it 'identifier_uri' do
        expect(subject).to respond_to(:identifier_uri)
        expect(subject).to respond_to(:identifier_uri=)
      end

      it 'note_internal' do
        expect(subject).to respond_to(:note_internal)
        expect(subject).to respond_to(:note_internal=)
      end

      it 'names' do
        expect(subject).to respond_to(:names)
        expect(subject).to respond_to(:names=)
      end

      it 'record_info_note' do
        expect(subject).to respond_to(:record_info_note)
        expect(subject).to respond_to(:record_info_note=)
      end

      it 'title' do
        expect(subject).to respond_to(:title)
        expect(subject).to respond_to(:title=)
      end
    end

    context ' has the following instance method:' do
      it '#parse method that takes file to parse' do
        expect(subject).to respond_to(:parse).with(1).arguments
      end
    end
  end

  context "In mets file containing expected elements" do
    mods_parser = Sword::Parsers::ModsParser.new
    mets_file = Rails.root.join "spec/fixtures/files/xml/mets/mods_mets.xml"
    nokogiri_xml = Nokogiri::XML(mets_file)
    xmlData_as_nokogiri_xml_element =
      nokogiri_xml.xpath('/xmlns:mets/xmlns:dmdSec/xmlns:mdWrap/xmlns:xmlData').first
    mods_parser.parse(xmlData_as_nokogiri_xml_element)

    it "parses the abstract correctly" do
      expect(mods_parser.abstract).to eq "This is the best self deposit ever"
    end

    it "parses the date issued (start date) correctly" do
      expect(mods_parser.date_issued_start).to eq "2018"
    end

    it "parses the DOI correctly" do
      expect(mods_parser.identifier_doi).to eq "10.1234/J7dyT"
    end

    it "parses the URI correctly" do
      expect(mods_parser.identifier_uri).to eq "https://boardgamegeek.com/boardgame/822/carcassonne"
    end

    it "parses the internal note correctly" do
      expect(mods_parser.note_internal).to eq "Note to catalogers."
    end

    it "parses the RecordInfoNote correctly" do
      expect(mods_parser.record_info_note).to eq "AC SWORD MODS v1.0"
    end

    it "parses the AccessCondition license uri correctly" do
      expect(mods_parser.access_condition_use_and_reproduction_license_uri
            ).to eq "https://creativecommons.org/licenses/by/4.0/"
    end

    it "parses the AccessCondition rights uri correctly" do
      expect(mods_parser.access_condition_use_and_reproduction_rights_status_uri
            ).to eq "http://rightsstatements.org/vocab/InC/1.0/"
    end

    it "parses the title correctly" do
      expect(mods_parser.title).to eq "Super Supreme Self Deposit"
    end

    context 'in MODS name element' do
      it "parses the MODS <name><namePart> content" do
        expect(mods_parser.names.first.name_part).to be_in(["Mouse, Mickey M.","Lacksauni, Generic"])
        expect(mods_parser.names.second.name_part).to be_in(["Mouse, Mickey M.","Lacksauni, Generic"])
      end

      it "parses the MODS <name ID=> attribute which contains the uni" do
        expect(mods_parser.names.first.id).to eq('mm314159265359')
      end
    end
  end

  context "In mets file containing various name elements" do
    mods_parser = Sword::Parsers::ModsParser.new
    mets_file = Rails.root.join "spec/fixtures/files/xml/mets/mods_name_mets.xml"
    nokogiri_xml = Nokogiri::XML(mets_file)
    xmlData_as_nokogiri_xml_element =
      nokogiri_xml.xpath('/xmlns:mets/xmlns:dmdSec/xmlns:mdWrap/xmlns:xmlData').first
    mods_parser.parse(xmlData_as_nokogiri_xml_element)

    it "parses the MODS <name><namePart> content" do
      expect(mods_parser.names.map{|e| e.name_part}).to include *["Mouse, Mickey M.","Goofy"]
    end

    it "parses multiple MODS <name><namePart> contained in one <name> and concatenates them" do
      expect(mods_parser.names.map{|e| e.name_part}).to include "Minnie Mouse Inc"
    end

    it "parses the ID atrribute of the <name> element" do
      expect(mods_parser.names.map{|e| e.id}).to include *['min314159265359',
                                                           'min314159265359',
                                                           'mic314159265359']
    end

    it "parses the type atrribute of the <name> element" do
      expect(mods_parser.names.map{|e| e.type}).to include *['personal',
                                                           'corporate']
    end

    it "parses the content of the <name><role><roleTerm>  element" do
      expect(mods_parser.names.map{|e| e.role.role_term}).to include *['Author']
    end

    it "parses the type attribute of the <name><role><roleTerm>  element" do
      expect(mods_parser.names.map{|e| e.role.role_term_type}).to include 'text'
    end

    it "parses the authority attribute of the <name><role><roleTerm>  element" do
      expect(mods_parser.names.map{|e| e.role.role_term_authority}).to include 'marcrelator'
    end

    it "parses the valueURI attribute of the <name><role><roleTerm>  element" do
      expect(mods_parser.names.map{|e| e.role.role_term_value_uri}).to include 'http://id.loc.gov/vocabulary/relators/aut'
    end
  end
end
