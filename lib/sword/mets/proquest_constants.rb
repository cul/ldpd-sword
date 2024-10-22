# frozen_string_literal: true

module Sword::Mets::ProquestConstants
  OTHER	= 'OTHER'
  OTHER_MDTYPE = 'PROQUEST'
  XPATH_INFO = { namespace: { 'etdsword' => 'http://www.etdadmin.com/ns/etdsword' },
                 abstract: '//etdsword:DISS_abstract',
                 author_name: '//etdsword:DISS_author/etdsword:DISS_name',
                 first_name: './etdsword:DISS_fname',
                 middle_name: './etdsword:DISS_middle',
                 subjects: '//etdsword:DISS_cat_desc',
                 surname: './etdsword:DISS_surname',
                 title: '//etdsword:DISS_title' }.freeze
end
