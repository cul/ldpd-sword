require 'rails_helper'

require 'sword/metadata/epdcx_bibliographic_citation.rb'

RSpec.describe Sword::Metadata::EpdcxBibliographicCitation do
  describe 'API/Interface' do
    context 'has attr_accessor for the following instance var:' do
      it 'issue' do
        expect(subject).to respond_to(:issue)
        expect(subject).to respond_to(:issue=)
      end

      it 'publish_year' do
        expect(subject).to respond_to(:publish_year)
        expect(subject).to respond_to(:publish_year=)
      end

      it 'start_page' do
        expect(subject).to respond_to(:start_page)
        expect(subject).to respond_to(:start_page=)
      end

      it 'title' do
        expect(subject).to respond_to(:title)
        expect(subject).to respond_to(:title=)
      end

      it 'volume' do
        expect(subject).to respond_to(:volume)
        expect(subject).to respond_to(:volume=)
      end
    end
  end
end
