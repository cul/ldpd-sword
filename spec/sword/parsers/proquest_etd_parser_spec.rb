require 'rails_helper'

require 'sword/parsers/proquest_etd_parser.rb'

# Parser based on mets.xml files received from ProQuest, and the DTD found at
# http://www.etdadmin.com/dtds/etd.dtd
RSpec.describe Sword::Parsers::ProquestEtdParser do
  ########################################## Initial state
  describe 'Initial state' do
    context '#initialize sets @names to' do
      proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
      it 'an empty array' do
        # expect(described_class.new.names).to be_an_instance_of(Array)
        expect(proquest_etd_parser.names).to be_an_instance_of(Array)
        expect(proquest_etd_parser.names.empty?).to be(true)
      end
    end
  end

  context "In mets file containing expected elements" do
    proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
    xml_file = Rails.root.join "spec/fixtures/mets_files/proquest_xmlData.xml"
    nokogiri_xml = Nokogiri::XML(xml_file)
    proquest_etd_parser.parse(nokogiri_xml)

    it "parses the abstract correctly" do
      expect(proquest_etd_parser.abstract).to eq "This is the best self deposit ever"
    end

    it "parses the date conferred correctly" do
      expect(proquest_etd_parser.date_conferred).to eq "2018"
    end

    it "parses the degree conferred correctly" do
      expect(proquest_etd_parser.degree).to eq "Ph.D."
    end

    it "parses the department name correctly" do
      expect(proquest_etd_parser.institution_department_name).to eq "Biological Sciences"
    end

    it "parses the name of the degree granting institution correctly" do
      expect(proquest_etd_parser.institution_name).to eq "Columbia University"
    end

    it "parses the school code correctly" do
      expect(proquest_etd_parser.institution_school_code).to eq "0054"
    end

    it "parses the subjects correctly" do
      expect(proquest_etd_parser.subjects).to include *['Biology','Developmental biology','Genetics']
    end

    it "parses the embargo code correctly" do
      expect(proquest_etd_parser.embargo_code).to eq '4'
    end

    it "parses the embargo release date correctly (embargo code set to 4)" do
      expect(proquest_etd_parser.embargo_release_date).to eq '2019-08-02'
    end

    context 'name elements' do
      it "parses the author content" do
        actual_authors = proquest_etd_parser.names.each.select { |name| name.role == 'author' }
        expect(actual_authors.size).to eq(1)
        expect(actual_authors.first.first_name).to eq('Mickey')
        expect(actual_authors.first.last_name).to eq('Mouse')
        expect(actual_authors.first.middle_name).to be_empty
      end

      it "parses the advisor content" do
        actual_advisors = proquest_etd_parser.names.each.select { |name| name.role == 'advisor' }
        expect(actual_advisors.size).to eq(1)
        expect(actual_advisors.first.first_name).to eq('Minnie')
        expect(actual_advisors.first.last_name).to eq('Mouse')
        expect(actual_advisors.first.middle_name).to eq('A')
      end
    end

    it "parses the title correctly" do
      expect(proquest_etd_parser.title).to eq "Spatially restricted regulation of cell competition by the cytokine Spaetzle"
    end
  end

  context "In mets file with embargo code set to 0" do
    proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
    xml_file = Rails.root.join "spec/fixtures/mets_files/proquest_embargo_code_0_xmlData.xml"
    nokogiri_xml = Nokogiri::XML(xml_file)
    proquest_etd_parser.parse(nokogiri_xml)

    it "parses the embargo release date correctly" do
      expect(proquest_etd_parser.embargo_release_date).to eq '2018-07-27'
    end
  end

  context "In mets file with embargo code set to 0, missing DISS_contact_effdt" do
    proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
    xml_file = Rails.root.join "spec/fixtures/mets_files/proquest_embargo_code_0_missing_DISS_contact_effdt_xmlData.xml"
    nokogiri_xml = Nokogiri::XML(xml_file)
    proquest_etd_parser.parse(nokogiri_xml)

    it "leaves the embargo date unset (i.e. equal to nil)" do
      expect(proquest_etd_parser.embargo_release_date).to eq nil
    end
  end

  context "In mets file with embargo code set to 1" do
    proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
    xml_file = Rails.root.join "spec/fixtures/mets_files/proquest_embargo_code_1_xmlData.xml"
    nokogiri_xml = Nokogiri::XML(xml_file)
    proquest_etd_parser.parse(nokogiri_xml)

    it "parses the embargo release date correctly" do
      expect(proquest_etd_parser.embargo_release_date).to eq '2019-01-27'
    end
  end

  context "In mets file with embargo code set to 2" do
    proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
    xml_file = Rails.root.join "spec/fixtures/mets_files/proquest_embargo_code_2_xmlData.xml"
    nokogiri_xml = Nokogiri::XML(xml_file)
    proquest_etd_parser.parse(nokogiri_xml)

    it "parses the embargo release date correctly" do
      expect(proquest_etd_parser.embargo_release_date).to eq '2019-07-27'
    end
  end

  context "In mets file with embargo code set to 3" do
    proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
    xml_file = Rails.root.join "spec/fixtures/mets_files/proquest_embargo_code_3_xmlData.xml"
    nokogiri_xml = Nokogiri::XML(xml_file)
    proquest_etd_parser.parse(nokogiri_xml)

    it "parses the embargo release date correctly" do
      expect(proquest_etd_parser.embargo_release_date).to eq '2020-07-27'
    end
  end

  context "In mets file with embargo code set to 4" do
    proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
    xml_file = Rails.root.join "spec/fixtures/mets_files/proquest_xmlData.xml"
    nokogiri_xml = Nokogiri::XML(xml_file)
    proquest_etd_parser.parse(nokogiri_xml)

    it "parses the embargo release date correctly" do
      expect(proquest_etd_parser.embargo_release_date).to eq '2019-08-02'
    end
  end

  context "In mets file with embargo code set to 4, missing DISS_contact_effdt" do
    proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
    xml_file = Rails.root.join "spec/fixtures/mets_files/proquest_embargo_code_4_missing_DISS_contact_effdt_xmlData.xml"
    nokogiri_xml = Nokogiri::XML(xml_file)
    proquest_etd_parser.parse(nokogiri_xml)

    it "parses the embargo release date correctly" do
      expect(proquest_etd_parser.embargo_release_date).to eq '2019-08-02'
    end
  end
end
