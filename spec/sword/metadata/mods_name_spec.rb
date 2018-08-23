require 'rails_helper'

RSpec.describe Sword::Metadata::ModsName do
  context "API/interface" do
    it 'has #name_part attr_accessor' do
      expect(subject).to respond_to(:name_part)
      expect(subject).to respond_to(:name_part=)
    end
    
    it 'has #id attr_accessor' do
      expect(subject).to respond_to(:id)
      expect(subject).to respond_to(:id=)
    end

    it 'has #role attr_accessor' do
      expect(subject).to respond_to(:role)
      expect(subject).to respond_to(:role=)
    end

    it 'has #type' do
      expect(subject).to respond_to(:type)
      expect(subject).to respond_to(:type=)
    end
  end

  describe Sword::Metadata::ModsName::Role do
    context "API/interface" do
      it 'has #role_term_type attr_accessor' do
        expect(subject).to respond_to(:role_term_type)
        expect(subject).to respond_to(:role_term_type=)
      end

      it 'has #role_term_value_uri attr_accessor' do
        expect(subject).to respond_to(:role_term_value_uri)
        expect(subject).to respond_to(:role_term_value_uri=)
      end

      it 'has #role_term_authority attr_accessor' do
        expect(subject).to respond_to(:role_term_authority)
        expect(subject).to respond_to(:role_term_authority=)
      end

      it 'has #role_term attr_accessor' do
        expect(subject).to respond_to(:role_term)
        expect(subject).to respond_to(:role_term=)
      end
    end
  end

  context "instantiation works and can set attributes" do
    mods_name = Sword::Metadata::ModsName.new
    mods_name.name_part = 'Mouse, Mickey'
    mods_name.id = 'mm314159265359'
    mods_name.type = 'personal'
    mods_name.role.role_term_type = 'text'
    mods_name.role.role_term_value_uri = 'http://id.loc.gov/vocabulary/relators/aut'
    mods_name.role.role_term_authority = 'marcrelator'
    mods_name.role.role_term = 'Author'

    it 'and read them out' do
      expect(mods_name.name_part).to eq 'Mouse, Mickey'
      expect(mods_name.id).to eq 'mm314159265359'
      expect(mods_name.type).to eq 'personal'
      expect(mods_name.role.role_term_type).to eq 'text'
      expect(mods_name.role.role_term_value_uri).to eq 'http://id.loc.gov/vocabulary/relators/aut'
      expect(mods_name.role.role_term_authority).to eq 'marcrelator'
      expect(mods_name.role.role_term).to eq 'Author'
    end
  end
end
