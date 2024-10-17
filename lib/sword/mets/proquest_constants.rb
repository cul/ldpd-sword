# frozen_string_literal: true

module Sword::Mets::ProquestConstants
  OTHER	= 'OTHER'
  OTHER_MDTYPE = 'PROQUEST'
  XPATH_HASH = { abstract: "'//diss:DISS_abstract', 'diss' => 'http://www.etdadmin.com/ns/etdsword'",
                 date_conferred: "'//diss:DISS_abstract', 'diss' => 'http://www.etdadmin.com/ns/etdsword'",
                 title: "'//diss:DISS_title', 'diss' => 'http://www.etdadmin.com/ns/etdsword'" }.freeze
end
