require 'rails_helper'

RSpec.describe Sword::Endpoints::Endpoint do
  let :ac_collection {
    Collection.new(name: "Academic Commons Test Collection",
                   atom_title: "Atom Title of Academic Test Collection",
                   slug: "academic-commons-test-collection",
                   parser: "academic-commons")
  }

  let :proquest_collection {
    Collection.new(name: "ProQuest Test Collection",
                   atom_title: "Atom Title of Proquest Test Collection",
                   slug: "proquest-test-collection",
                   parser: "proquest")
  }

  let :springer_nature_collection {
    Collection.new(name: "Springer Nature Test Collection",
                   atom_title: "Atom Title of Springer Nature Test Collection",
                   slug: "springer-nature-test-collection",
                   parser: "springer-nature")
  }

  xdescribe '::get_endpoint' do
    context "if argument is 'academic-commons'" do
      it 'returns a Sword::Endpoints::AcademicCommonsEndpoint instance' do
        expect(Sword::Endpoints::Endpoint.get_endpoint(ac_collection,
                                                       Depositor.new)).to be_instance_of(Sword::Endpoints::AcademicCommonsEndpoint)
      end
    end

    context "if argument is 'proquest'" do
      it 'returns a Sword::Endpoints::ProquestEndpoint instance' do
        expect(Sword::Endpoints::Endpoint.get_endpoint(proquest_collection,
                                                       Depositor.new)).to be_instance_of(Sword::Endpoints::ProquestEndpoint)
      end
    end

    context "if argument is 'springer-nature'" do
      it 'returns a Sword::Endpoints::SpringerNatureEndpoint instance' do
        expect(Sword::Endpoints::Endpoint.get_endpoint(springer_nature_collection,
                                                       Depositor.new)).to be_instance_of(Sword::Endpoints::SpringerNatureEndpoint)
      end
    end

    xcontext "if argument is 'tow-journalism'" do
      it 'returns a Sword::Parsers::TowJournalismParser instance' do
        expect(subject.class.get_parser 'tow-journalism').to be_instance_of(Sword::Parsers::TowJournalismParser)
      end
    end
  end
end
