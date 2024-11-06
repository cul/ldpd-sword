# frozen_string_literal: true

module Sword::Mets::ProquestConstants
  OTHER	= 'OTHER'
  OTHER_MDTYPE = 'PROQUEST'
  XPATH_INFO = { namespace: { 'etdsword' => 'http://www.etdadmin.com/ns/etdsword' },
                 abstract: '//etdsword:DISS_abstract',
                 author_name: '//etdsword:DISS_author/etdsword:DISS_name',
                 comp_date: '//etdsword:DISS_comp_date',
                 degree: '//etdsword:DISS_degree',
                 embargo_code: '//etdsword:DISS_submission/@embargo_code',
                 institution_code: '//etdsword:DISS_inst_code',
                 institution_contact: '//etdsword:DISS_inst_contact',
                 institution_name: '//etdsword:DISS_inst_name',
                 first_name: './etdsword:DISS_fname',
                 middle_name: './etdsword:DISS_middle',
                 subjects: '//etdsword:DISS_cat_desc',
                 surname: './etdsword:DISS_surname',
                 title: '//etdsword:DISS_title' }.freeze
end
