require 'rails_helper'

require 'sword/parsers/eprints_dc_xml_parser.rb'

RSpec.describe Sword::Parsers::EprintsDcXmlParser do
  let(:nokogiri_xml) { Nokogiri::XML(xml_file) }
  ########################################## Initial state
  describe 'Initial state' do
    context '#initialize sets @creators to' do
      it 'an empty array' do
        expect(subject.creators).to be_an_instance_of(Array)
        expect(subject.creators.empty?).to be(true)
      end
    end

    context '#initialize sets @subjects to' do
      it 'an empty array' do
        expect(subject.subjects).to be_an_instance_of(Array)
        expect(subject.subjects.empty?).to be(true)
      end
    end
  end

  ########################################## #parse_bibliographic_citation
  describe '#parse_bibliographic_citation' do
    context "with bibliographic citation title set to 'Conflict and Health'" do
      xml_file = Rails.root.join "spec/fixtures/mets_files/springer-nature-bibcitation-1-xmlData.xml"
      nokogiri_xml = Nokogiri::XML(xml_file)
      parser = Sword::Parsers::EprintsDcXmlParser.new
      parser.parse_bibliographic_citation nokogiri_xml
      actual_citation = parser.bibliographic_citation
      expected_citation = Sword::Metadata::EpdcxBibliographicCitation.new
      expected_citation.issue = '1'
      expected_citation.publish_year = '2018'
      expected_citation.start_page = '37'
      expected_citation.title = 'Conflict and Health'
      expected_citation.volume = '12'

      it "parses the bibligraphic citation issue correctly" do
        expect(actual_citation.issue).to eq expected_citation.issue
      end

      it "parses the bibligraphic citation publish_year correctly" do
        expect(actual_citation.publish_year).to eq expected_citation.publish_year
      end

      it "parses the bibligraphic citation start_page correctly" do
        expect(actual_citation.start_page).to eq expected_citation.start_page
      end

      it "parses the bibligraphic citation title correctly" do
        expect(actual_citation.title).to eq expected_citation.title
      end

      it "parses the bibligraphic citation volume correctly" do
        expect(actual_citation.volume).to eq expected_citation.volume
      end
    end

    context "with bibliographic citation title set to 'Stem Cell Research & Therapy' (note the '&', coded as '&amp;' in the incoming xml" do
      xml_file = Rails.root.join "spec/fixtures/mets_files/springer-nature-bibcitation-2-xmlData.xml"
      nokogiri_xml = Nokogiri::XML(xml_file)
      parser = Sword::Parsers::EprintsDcXmlParser.new
      parser.parse_bibliographic_citation nokogiri_xml
      actual_citation = parser.bibliographic_citation
      expected_citation = Sword::Metadata::EpdcxBibliographicCitation.new
      expected_citation.issue = '1'
      expected_citation.publish_year = '2018'
      expected_citation.start_page = '229'
      expected_citation.title = 'Stem Cell Research & Therapy'
      expected_citation.volume = '9'
      expected_citation

      it "parses the bibligraphic citation issue correctly" do
        expect(actual_citation.issue).to eq expected_citation.issue
      end

      it "parses the bibligraphic citation publish_year correctly" do
        expect(actual_citation.publish_year).to eq expected_citation.publish_year
      end

      it "parses the bibligraphic citation start_page correctly" do
        expect(actual_citation.start_page).to eq expected_citation.start_page
      end

      it "parses the bibligraphic citation title correctly" do
        expect(actual_citation.title).to eq expected_citation.title
      end

      it "parses the bibligraphic citation volume correctly" do
        expect(actual_citation.volume).to eq expected_citation.volume
      end
    end
  end

  ########################################## #parse
  describe '#parse' do
    before { subject.parse nokogiri_xml }

    context "In mets file containing expected elements" do
      let(:xml_file) { Rails.root.join "spec/fixtures/mets_files/eprint_xmlData.xml" }

      it "parses the abstract correctly" do
        expect(subject.abstract).to eq "This is the abstract"
      end

      it "parses the date available correctly" do
        expect(subject.date_available).to eq "2018-08-06"
      end

      it "parses the date available (year) correctly" do
        expect(subject.date_available_year).to eq "2018"
      end

      context 'in creators arrays' do
        let(:expected_names) { ['Muhanguzi, Florence K','Mootz, Jennifer J','Panko, Pavel'] }
        it "parses names correctly" do
          expect(subject.creators).to contain_exactly(*expected_names)
        end
      end

      it "parses the identfier correctly" do
        expect(subject.identifier).to eq "https://doi.org/10.1186/s13031-018-0173-x"
      end

      it "parses the identfier URI correctly" do
        expect(subject.identifier_uri).to eq "https://doi.org/10.1186/s13031-018-0173-x"
      end

      it "parses the publisher correctly" do
        expect(subject.publisher).to eq "BioMed Central"
      end

      context 'in subjects arrays' do
        let(:expected_subjects) { ['Alcohol use','Armed conflict','Uganda'] }
        it "parses subjects correctly" do
           expect(subject.subjects).to contain_exactly(*expected_subjects)
        end
      end

      it "parses the title correctly" do
        expect(subject.title).to eq "Armed conflict in Northeastern Uganda: a population level study"
      end
    end

    ########################################## #parse no bliblio
    context "In mets file containing expected elements but no bibliogtaphic citation" do
      let(:xml_file) { Rails.root.join "spec/fixtures/mets_files/eprint_xmlData_no_biblio_citation.xml" }

      it "parses the abstract correctly" do
        expect(subject.abstract).to eq "This is the abstract"
      end

      it "parses the date available correctly" do
        expect(subject.date_available).to eq "2018-08-06"
      end

      it "parses the date available (year) correctly" do
        expect(subject.date_available_year).to eq "2018"
      end

      context 'in creators arrays' do
        let(:expected_names) { ['Muhanguzi, Florence K','Mootz, Jennifer J','Panko, Pavel'] }
        it "parses names correctly" do
          expect(subject.creators).to contain_exactly(*expected_names)
        end
      end

      it "parses the identfier correctly" do
        expect(subject.identifier).to eq "https://doi.org/10.1186/s13031-018-0173-x"
      end

      it "parses the identfier URI correctply" do
        expect(subject.identifier_uri).to eq "https://doi.org/10.1186/s13031-018-0173-x"
      end

      it "parses the publisher correctly" do
        expect(subject.publisher).to eq "BioMed Central"
      end

      context 'in subjects arrays' do
        let(:expected_subjects) { ['Alcohol use','Armed conflict','Uganda'] }
        it "parses subjects correctly" do
          expect(subject.subjects).to contain_exactly(*expected_subjects)
        end
      end

      it "parses the title correctly" do
        expect(subject.title).to eq "Armed conflict in Northeastern Uganda: a population level study"
      end
    end
  end
end
