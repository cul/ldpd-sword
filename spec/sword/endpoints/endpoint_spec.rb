require 'rails_helper'

RSpec.describe Sword::Endpoints::Endpoint do
  describe '::get_endpoint' do
    context "if argument is 'academic-commons'" do
      it 'returns a Sword::Endpoints::AcademicCommonsEndpoint instance' do
        expect(Sword::Endpoints::Endpoint.get_endpoint('test-ac',
                                                       'firsttestdepositor')).to be_instance_of(Sword::Endpoints::AcademicCommonsEndpoint)
      end
    end

    context "if argument is 'proquest'" do
      it 'returns a Sword::Endpoints::ProquestEndpoint instance' do
        expect(Sword::Endpoints::Endpoint.get_endpoint('test-pq',
                                                       'firsttestdepositor')).to be_instance_of(Sword::Endpoints::ProquestEndpoint)
      end
    end

    context "if argument is 'springer-nature'" do
      it 'returns a Sword::Endpoints::SpringerNatureEndpoint instance' do
        expect(Sword::Endpoints::Endpoint.get_endpoint('test-sn',
                                                       'firsttestdepositor')).to be_instance_of(Sword::Endpoints::SpringerNatureEndpoint)
      end
    end
  end
end
