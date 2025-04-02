require 'rails_helper'

require 'sword/metadata/mods_name.rb'

RSpec.describe Sword::Metadata::ModsName do
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
