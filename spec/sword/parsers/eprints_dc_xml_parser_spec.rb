require 'rails_helper'

RSpec.describe Sword::Parsers::EprintsDcXmlParser do
  ########################################## Initial state
  describe 'Initial state' do
    let :proquest_etd_parser { Sword::Parsers::EprintsDcXmlParser.new }
    context '#initialize sets @creators to' do
      it 'an empty array' do
        expect(proquest_etd_parser.creators).to be_an_instance_of(Array)
        expect(proquest_etd_parser.creators.empty?).to be(true)
      end
    end

    context '#initialize sets @subjects to' do
      it 'an empty array' do
        expect(proquest_etd_parser.subjects).to be_an_instance_of(Array)
        expect(proquest_etd_parser.subjects.empty?).to be(true)
      end
    end
  end

  ########################################## API/interface
  describe 'API/interface' do
    context 'has attr_accessor for instance var' do
      # http://purl.org/dc/terms/abstract
      # http://dublincore.org/documents/dcmi-terms/#terms-abstract
      it 'abstract' do
        expect(subject).to respond_to(:abstract)
        expect(subject).to respond_to(:abstract=)
      end

      # http://purl.org/eprint/terms/bibliographicCitation
      it 'bibliographic_citation' do
        expect(subject).to respond_to(:bibliographic_citation)
        expect(subject).to respond_to(:bibliographic_citation=)
      end

      # http://purl.org/dc/elements/1.1/creator
      # http://dublincore.org/documents/dcmi-terms/#terms-creator
      it 'creators' do
        expect(subject).to respond_to(:creators)
        expect(subject).to respond_to(:creators=)
      end

      # http://purl.org/dc/terms/available
      # http://dublincore.org/documents/dcmi-terms/#terms-available
      # format: YYYY-MM-DD
      it 'date_available' do
        expect(subject).to respond_to(:date_available)
        expect(subject).to respond_to(:date_available=)
      end

      # http://purl.org/dc/elements/1.1/identifier
      # Idenfifier is a URI: http://purl.org/dc/terms/URI
      # in this case, uri will be a doi
      # http://dublincore.org/documents/dcmi-terms/#terms-identifier
      it 'identifier_uri' do
        expect(subject).to respond_to(:identifier_uri)
        expect(subject).to respond_to(:identifier_uri=)
      end

      # http://purl.org/dc/elements/1.1/subject
      # http://dublincore.org/documents/dcmi-terms/#terms-subject
      it 'subjects' do
        expect(subject).to respond_to(:subjects)
        expect(subject).to respond_to(:subjects=)
      end

      # http://purl.org/dc/elements/1.1/title
      # http://dublincore.org/documents/dcmi-terms/#terms-title
      it 'title' do
        expect(subject).to respond_to(:title)
        expect(subject).to respond_to(:title=)
      end
    end

    context ' has the following instance method:' do
      it '#parse method that takes file to parse' do
        expect(subject).to respond_to(:parse).with(1).arguments
      end

      # http://purl.org/dc/terms/available
      # http://dublincore.org/documents/dcmi-terms/#terms-available
      # method will parse out the year from the YYYY-MM-DD format
      # so returns YYYY
      it 'date_available_year' do
        expect(subject).to respond_to(:date_available_year)
      end
    end
  end

  ########################################## #parse
  describe '#parse' do
    context "In mets file containing expected elements" do
      epdcx_parser = Sword::Parsers::EprintsDcXmlParser.new
      xml_file = Rails.root.join "spec/fixtures/mets_files/springer-nature-1-xmlData.xml"
      nokogiri_xml = Nokogiri::XML(xml_file)
      epdcx_parser.parse(nokogiri_xml)

      it "parses the abstract correctly" do
        expect(epdcx_parser.abstract).to eq "This is the abstract"
      end

      it "parses the date available correctly" do
        expect(epdcx_parser.date_available).to eq "2018-08-06"
      end

      it "parses the date available (year) correctly" do
        expect(epdcx_parser.date_available_year).to eq "2018"
      end

      context 'in creators arrays' do
        it "parses names correctly" do
          names = ['Muhanguzi, Florence K','Mootz, Jennifer J','Panko, Pavel']
          expect(epdcx_parser.creators.first).to be_in(names)
          expect(epdcx_parser.creators.second).to be_in(names)
          expect(epdcx_parser.creators.third).to be_in(names)
        end
      end

      it "parses the identfier URI correctly" do
        expect(epdcx_parser.identifier_uri).to eq "https://doi.org/10.1186/s13031-018-0173-x"
      end

      context 'in subjects arrays' do
        it "parses subjects correctly" do
          subjects = ['Alcohol use','Armed conflict','Uganda']
          expect(epdcx_parser.subjects.first).to be_in(subjects)
          expect(epdcx_parser.subjects.second).to be_in(subjects)
          expect(epdcx_parser.subjects.third).to be_in(subjects)
        end
      end

      it "parses the title correctly" do
        expect(epdcx_parser.title).to eq "Armed conflict in Northeastern Uganda: a population level study"
      end
    end
  end
end
