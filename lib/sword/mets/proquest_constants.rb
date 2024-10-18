# frozen_string_literal: true

module Sword::Mets::ProquestConstants
  OTHER	= 'OTHER'
  OTHER_MDTYPE = 'PROQUEST'
  XPATH_INFO = { namespace: { 'etdsword' => 'http://www.etdadmin.com/ns/etdsword' },
                 abstract: '//etdsword:DISS_abstract',
                 subjects: '//etdsword:DISS_cat_desc',
                 title: '//etdsword:DISS_title' }.freeze
end
