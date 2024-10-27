require 'rails_helper'

require 'sword/metadata/note.rb'

RSpec.describe Sword::Metadata::Note do
  describe 'API/Interface' do
    subject { Sword::Metadata::Note.new('') }
    context 'has the following attr_accessor:' do
      it 'value' do
        expect(subject).to respond_to(:content)
        expect(subject).to respond_to(:content=)
      end

      it 'type' do
        expect(subject).to respond_to(:type)
        expect(subject).to respond_to(:type=)
      end
    end
  end
end
