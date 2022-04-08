require 'rails_helper'

require 'sword/metadata/degree.rb'

RSpec.describe Sword::Metadata::Degree do
  describe 'API/Interface' do
    context 'has the following attr_accessor:' do
      it 'discipline' do
        expect(subject).to respond_to(:discipline)
        expect(subject).to respond_to(:discipline=)
      end

      it 'grantor' do
        expect(subject).to respond_to(:grantor)
        expect(subject).to respond_to(:grantor=)
      end

      it 'level' do
        expect(subject).to respond_to(:level)
        expect(subject).to respond_to(:level=)
      end

      it 'name' do
        expect(subject).to respond_to(:name)
        expect(subject).to respond_to(:name=)
      end
    end
  end
end
