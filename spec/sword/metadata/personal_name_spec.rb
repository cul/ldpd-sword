require 'rails_helper'

RSpec.describe Sword::Metadata::PersonalName do
  describe 'API/Interface' do
    context 'has attr_accessor for' do
      it 'first_name' do
        expect(subject).to respond_to(:first_name)
        expect(subject).to respond_to(:first_name=)
      end

      it 'full_name_naf_format' do
        expect(subject).to respond_to(:full_name_naf_format)
        expect(subject).to respond_to(:full_name_naf_format=)
      end

      it 'last_name' do
        expect(subject).to respond_to(:last_name)
        expect(subject).to respond_to(:last_name=)
      end

      it 'middle_name' do
        expect(subject).to respond_to(:middle_name)
        expect(subject).to respond_to(:middle_name=)
      end

      it 'role' do
        expect(subject).to respond_to(:role)
        expect(subject).to respond_to(:role=)
      end

      it 'type' do
        expect(subject).to respond_to(:type)
        expect(subject).to respond_to(:type=)
      end

      it 'uni' do
        expect(subject).to respond_to(:uni)
        expect(subject).to respond_to(:uni=)
      end
    end
  end
end
