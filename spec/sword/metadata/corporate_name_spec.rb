require 'rails_helper'

require 'sword/metadata/corporate_name.rb'

RSpec.describe Sword::Metadata::CorporateName do
  describe 'API/Interface' do
    context 'has attr_accessor for' do
      it 'name' do
        expect(subject).to respond_to(:name)
        expect(subject).to respond_to(:name=)
      end

      it 'role' do
        expect(subject).to respond_to(:role)
        expect(subject).to respond_to(:role=)
      end
    end
  end
end
