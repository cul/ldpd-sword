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

  ########################################## API/interface
  describe 'API/interface' do
    context 'has attr_accessor for instance var' do
      it 'abstract' do
        expect(subject).to respond_to(:abstract)
        expect(subject).to respond_to(:abstract=)
      end

      it 'date_conferred' do
        expect(subject).to respond_to(:date_conferred)
        expect(subject).to respond_to(:date_conferred=)
      end

      # Conforms to ProQuest list of degree acronyms
      it 'degree' do
        expect(subject).to respond_to(:degree)
        expect(subject).to respond_to(:degree=)
      end

      # Code to figure out the embargo date
      it 'embargo_code' do
        expect(subject).to respond_to(:embargo_code)
        expect(subject).to respond_to(:embargo_code=)
      end

      # Embargo release date, which is when the dissertation can be released. This date is derived,
      # depending on the embargo code, on various other dates in the ProQuest metadata. See the
      # definition of the calculate_embargo_release_date instance method for details
      it 'embargo_release_date' do
        expect(subject).to respond_to(:embargo_release_date)
        expect(subject).to respond_to(:embargo_release_date=)
      end

      # Department name within the institution
      it 'institution_department_name' do
        expect(subject).to respond_to(:institution_department_name)
        expect(subject).to respond_to(:institution_department_name=)
      end

      # the name of the degree granting institution
      it 'institution_name' do
        expect(subject).to respond_to(:institution_name)
        expect(subject).to respond_to(:institution_name=)
      end

      # PQ-assigned school code (I assume PQ means ProQuest)
      it 'institution_school_code' do
        expect(subject).to respond_to(:institution_school_code)
        expect(subject).to respond_to(:institution_school_code=)
      end

      it 'names' do
        expect(subject).to respond_to(:names)
        expect(subject).to respond_to(:names=)
      end

      it 'subjects' do
        expect(subject).to respond_to(:subjects)
        expect(subject).to respond_to(:subjects=)
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

      it '#parse_subjects ' do
        expect(subject).to respond_to(:parse_subjects).with(1).arguments
      end

      # Following has info on calculating the embargo release date:
      # https://support.proquest.com/#articledetail?id=kA0400000004JJCCA2&key=embargo&pcat=All__c&icat=
      # The ETD mentioned at the top of this file also has info on the embargo date
      it '#calculate_embargo_release_date ' do
        expect(subject).to respond_to(:calculate_embargo_release_date).with(1).arguments
      end
    end
  end

  context "In mets file containing expected elements" do
    proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
    xml_file = Rails.root.join "spec/fixtures/files/xml/mets/proquest_xmlData.xml"
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
    xml_file = Rails.root.join "spec/fixtures/files/xml/mets/proquest_embargo_code_0_xmlData.xml"
    nokogiri_xml = Nokogiri::XML(xml_file)
    proquest_etd_parser.parse(nokogiri_xml)

    it "parses the embargo release date correctly" do
      expect(proquest_etd_parser.embargo_release_date).to eq '2018-07-27'
    end
  end

  context "In mets file with embargo code set to 0, missing DISS_contact_effdt" do
    proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
    xml_file = Rails.root.join "spec/fixtures/files/xml/mets/proquest_embargo_code_0_missing_DISS_contact_effdt_xmlData.xml"
    nokogiri_xml = Nokogiri::XML(xml_file)
    proquest_etd_parser.parse(nokogiri_xml)

    it "leaves the embargo date unset (i.e. equal to nil)" do
      expect(proquest_etd_parser.embargo_release_date).to eq nil
    end
  end

  context "In mets file with embargo code set to 1" do
    proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
    xml_file = Rails.root.join "spec/fixtures/files/xml/mets/proquest_embargo_code_1_xmlData.xml"
    nokogiri_xml = Nokogiri::XML(xml_file)
    proquest_etd_parser.parse(nokogiri_xml)

    it "parses the embargo release date correctly" do
      expect(proquest_etd_parser.embargo_release_date).to eq '2019-01-27'
    end
  end

  context "In mets file with embargo code set to 2" do
    proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
    xml_file = Rails.root.join "spec/fixtures/files/xml/mets/proquest_embargo_code_2_xmlData.xml"
    nokogiri_xml = Nokogiri::XML(xml_file)
    proquest_etd_parser.parse(nokogiri_xml)

    it "parses the embargo release date correctly" do
      expect(proquest_etd_parser.embargo_release_date).to eq '2019-07-27'
    end
  end

  context "In mets file with embargo code set to 3" do
    proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
    xml_file = Rails.root.join "spec/fixtures/files/xml/mets/proquest_embargo_code_3_xmlData.xml"
    nokogiri_xml = Nokogiri::XML(xml_file)
    proquest_etd_parser.parse(nokogiri_xml)

    it "parses the embargo release date correctly" do
      expect(proquest_etd_parser.embargo_release_date).to eq '2020-07-27'
    end
  end

  context "In mets file with embargo code set to 4" do
    proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
    xml_file = Rails.root.join "spec/fixtures/files/xml/mets/proquest_xmlData.xml"
    nokogiri_xml = Nokogiri::XML(xml_file)
    proquest_etd_parser.parse(nokogiri_xml)

    it "parses the embargo release date correctly" do
      expect(proquest_etd_parser.embargo_release_date).to eq '2019-08-02'
    end
  end

  context "In mets file with embargo code set to 4, missing DISS_contact_effdt" do
    proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
    xml_file = Rails.root.join "spec/fixtures/files/xml/mets/proquest_embargo_code_4_missing_DISS_contact_effdt_xmlData.xml"
    nokogiri_xml = Nokogiri::XML(xml_file)
    proquest_etd_parser.parse(nokogiri_xml)

    it "parses the embargo release date correctly" do
      expect(proquest_etd_parser.embargo_release_date).to eq '2019-08-02'
    end
  end
end
