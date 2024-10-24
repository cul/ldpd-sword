# frozen_string_literal: true

module Sword::Mets::EprintsDcConstants
  OTHER	= 'OTHER'
  OTHER_MDTYPE = 'EPDCX'
  XPATH_INFO = { namespace: { 'epdcx' => 'http://purl.org/eprint/epdcx/2006-11-16/' },
                 abstract: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/terms/abstract"]',
                 date_available: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/terms/available"]',
                 title: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/elements/1.1/title"]' }.freeze
end
