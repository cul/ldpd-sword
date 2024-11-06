# frozen_string_literal: true

module Sword::Mets::EprintsDcConstants
  OTHER	= 'OTHER'
  OTHER_MDTYPE = 'EPDCX'
  XPATH_INFO = { namespace: { 'epdcx' => 'http://purl.org/eprint/epdcx/2006-11-16/' },
                 abstract: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/terms/abstract"]',
                 bibliographic_citation: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/eprint/terms/bibliographicCitation"]',
                 creator: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/elements/1.1/creator"]',
                 date_available: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/terms/available"]',
                 identifier_uri: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/elements/1.1/identifier"]/epdcx:valueString[@epdcx:sesURI="http://purl.org/dc/terms/URI"]',
                 publisher: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/elements/1.1/publisher"]',
                 title: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/elements/1.1/title"]' }.freeze
end
