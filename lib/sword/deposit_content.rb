module Sword
  class DepositContent
    DATE_PATTERN = '%Y-%m-%d'
    attr_accessor :title,
                  :abstract,
                  :subjects,
                  :genre_uri,
                  :source,
                  :language,
                  :physicalLocation,
                  :recordContentSource,
                  :languageOfCataloging,
                  :issn,
                  :pubdate,
                  :dateIssued,
                  :volume,
                  :issue,
                  :fpage,
                  :ezid_doi,
                  :pub_doi,
                  :copyrightNotice,
                  :type_of_resource,
                  :type_of_content,
                  :authors,
                  :advisors,
                  :corporate_name,
                  :corporate_role,
                  :attachments,
                  :embargo_start_date,
                  :embargo_code,
                  :sales_restriction_date,
                  :note
    def embargo_release_date
      DepositContent.getEmbargoDate(self)
    end
    def self.getEmbargoDate(deposit_content)

      embargo_release_date = nil

      start_date = Date.parse(deposit_content.embargo_start_date)

      if(deposit_content.embargo_code == '1')
        embargo_release_date = (start_date + 6.month)
      end

      if(deposit_content.embargo_code == '2') 
        embargo_release_date = (start_date + 1.year)
      end
      
      if(deposit_content.embargo_code == '3')
        embargo_release_date = (start_date + 2.year)
      end
      
      if(deposit_content.embargo_code == '0')
        embargo_release_date = start_date
      end

      if(deposit_content.embargo_code == '4')
        if deposit_content.sales_restriction_date
          embargo_release_date =
            Date.parse(deposit_content.sales_restriction_date)
        end
      end

      return  embargo_release_date ? embargo_release_date.strftime(DATE_PATTERN) : ''
    end
  end
end
