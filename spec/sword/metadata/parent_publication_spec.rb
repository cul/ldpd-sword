require 'rails_helper'

RSpec.describe Sword::Metadata::ParentPublication do
  describe 'API/Interface' do
    context 'has attr_accessor for the following instance var:' do
      it 'doi' do
        expect(subject).to respond_to(:doi)
        expect(subject).to respond_to(:doi=)
      end

      it 'issue' do
        expect(subject).to respond_to(:issue)
        expect(subject).to respond_to(:issue=)
      end

      it 'publish_date' do
        expect(subject).to respond_to(:publish_date)
        expect(subject).to respond_to(:publish_date=)
      end

      it 'start_page' do
        expect(subject).to respond_to(:start_page)
        expect(subject).to respond_to(:start_page=)
      end

      it 'title' do
        expect(subject).to respond_to(:title)
        expect(subject).to respond_to(:title=)
      end

      it 'uri' do
        expect(subject).to respond_to(:uri)
        expect(subject).to respond_to(:uri=)
      end

      it 'volume' do
        expect(subject).to respond_to(:volume)
        expect(subject).to respond_to(:volume=)
      end
    end
  end
end
