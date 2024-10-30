# frozen_string_literal: true

module Sword::Mets::ModsConstants
  OTHER = 'MODS'
  OTHER_MDTYPE = nil
  XPATH_INFO =
    { namespace: { 'mods' => 'http://www.loc.gov/mods/v3' },
      abstract: '//mods:abstract',
      author: '//mods:namePart',
      license_uri: '//mods:accessCondition[@displayLabel="License"]',
      note_internal: '//mods:note[@type="internal"]',
      title: '//mods:titleInfo/mods:title',
      use_and_reproduction_uri: '//mods:accessCondition[@displayLabel="Rights Status"]' }.freeze
end
