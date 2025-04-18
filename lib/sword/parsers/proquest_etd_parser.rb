require 'sword/metadata/mods_name.rb'
require 'sword/metadata/personal_name.rb'

# Parser based on mets.xml files received from ProQuest, and the DTD found at
# http://www.etdadmin.com/dtds/etd.dtd
module Sword
  module Parsers
    class ProquestEtdParser

      attr_accessor :abstract,
                    :date_conferred,
                    :degree,
                    :embargo_code,
                    :embargo_release_date,
                    :institution_department_name,
                    :institution_name,
                    :institution_school_code,
                    :names,
                    :subjects,
                    :title

      def initialize
        @names = []
        @subjects = []
      end

      def parse(xmlData_nokogiri_xml)
        # From DTD (see comment at top of file):
        # DISS_abstract contains one or more paragraphs of text abstract from the author
        @abstract =
          xmlData_nokogiri_xml.css("DISS_content>DISS_abstract").first.text

        # From DTD (see comment at top of file):
        # DISS_comp_date refers to the year the degree was conferred
        @date_conferred =
          xmlData_nokogiri_xml.css("DISS_description>DISS_dates>DISS_comp_date").first.text

        # From DTD (see comment at top of file):
        # Conforms to ProQuest list of degree acronyms
        @degree =
          xmlData_nokogiri_xml.css("DISS_description>DISS_degree").first.text

        # From DTD (see comment at top of file):
        # Attribute of <DISS_submission>, possible values 0 thru 4. See DTD for details
        @embargo_code =
          xmlData_nokogiri_xml.css("DISS_submission").first["embargo_code"]

        # From DTD (see comment at top of file):
        # Department name within the institution
        @institution_department_name =
          xmlData_nokogiri_xml.css("DISS_description>DISS_institution>DISS_inst_contact").first.text

        # From DTD (see comment at top of file):
        # the name of the degree granting institution
        @institution_name =
          xmlData_nokogiri_xml.css("DISS_description>DISS_institution>DISS_inst_name").first.text

        # From DTD (see comment at top of file):
        # DISS_inst_code is a PQ-assigned school code
        @institution_school_code =
          xmlData_nokogiri_xml.css("DISS_description>DISS_institution>DISS_inst_code").first.text

        # From DTD (see comment at top of file):
        # DISS_title is the full title of the dissertation
        @title =
          xmlData_nokogiri_xml.css("DISS_title").first.text

        parse_authors xmlData_nokogiri_xml
        parse_advisors xmlData_nokogiri_xml
        parse_subjects xmlData_nokogiri_xml
        calculate_embargo_release_date xmlData_nokogiri_xml
      end

      def parse_subjects(nokogiri_xml)
        nokogiri_xml.css("DISS_description>DISS_categorization>DISS_category").each do |category|
          @subjects.push(category.css("DISS_cat_desc").text)
        end
      end

      def parse_authors(nokogiri_xml)
        nokogiri_xml.css("DISS_authorship>DISS_author").each do |author|
          person = Sword::Metadata::PersonalName.new
          person.last_name = author.css("DISS_surname").text
          person.first_name = author.css("DISS_fname").text
          person.middle_name = author.css("DISS_middle").text
          person.role = 'author'
          # person.affiliation = getAffiliation(contentXml)
          # person.degree = DEGREE
          # person.degree_grantor = DEGREE_GRANTOR
          @names << person
        end
      end

      def parse_advisors(nokogiri_xml)
        nokogiri_xml.css("DISS_description>DISS_advisor").each do |advisor|
          person = Sword::Metadata::PersonalName.new
          person.last_name = advisor.css("DISS_surname").text
          person.first_name = advisor.css("DISS_fname").text
          person.middle_name = advisor.css("DISS_middle").text
          person.role = 'advisor'
          # person.affiliation = getAffiliation(contentXml)
          # person.degree = DEGREE
          # person.degree_grantor = DEGREE_GRANTOR
          @names << person
        end
      end

      # This method calculates the embargo release date. More info can be found in the ProQuest ETD,
      # (see link mentioned in comment at top of this file), as well
      # as the following ProQuest support center article:
      # https://support.proquest.com/#articledetail?id=kA0400000004JJCCA2&key=embargo&pcat=All__c&icat=
      # Note that we use the date contained in DISS_contact_effdt as the date that the manuscript was
      # received by ProQuest

      # Following was copied from the ProQuest ETD
      # please note that formatting, such as tabs, was lost during the current and paste below
      # BEGIN_CUT_AND_PASTE_BLURB>>>>>>
      # *Embargo code can be (this is the ProQuest embargo, not the IR embargo):
      # 0 - no embargo
      # 1 - 6 month embargo
      # 2 - 1 year embargo
      # 3 - 2 year embargo
      # 4 - flexible delayed release
      # Note: if embargo code = 4
      # sales_restriction 1 (in the DISS_restriction element) should be
      # populated. The corresponding "remove" attribute of the
      # sales_restriction element should have the delayed release date chosen
      # by the author/administrator. In case the author chooses to never
      # release his/her work the corresponding "remove" date on the
      # restriction should be null.
      # Examples:
      # embargo_code = 4,
      # Diss_sales_restriction = 1,
      # remove = 01/01/2010 (delayed release until 01/01/2010)
      #
      # embargo_code = 4,
      # Diss_sales_restriction = 1,
      # remove = null (never to be released)
      #
      # Diss_sales_restriction need not be populated for embargo options
      # 1, 2 and 3 since the release date is implied.
      # <<<<<<END_CUT_AND_PASTE_BLURB
      def calculate_embargo_release_date(nokogiri_xml)
        @embargo_release_date
        diss_contact_effdt_nokogiri_node_element = nokogiri_xml.css("DISS_authorship>DISS_author>DISS_contact>DISS_contact_effdt").first
        diss_contact_effdt = diss_contact_effdt_nokogiri_node_element.text if diss_contact_effdt_nokogiri_node_element

        # start_date = Date.parse(deposit_content.embargo_start_date)
        embargo_start_date_object = Date.strptime(diss_contact_effdt, "%m/%d/%Y") if diss_contact_effdt

        case @embargo_code
        when '0'
          @embargo_release_date = embargo_start_date_object.strftime('%Y-%m-%d') if embargo_start_date_object
        when '1'
          @embargo_release_date = (embargo_start_date_object + 6.month).strftime('%Y-%m-%d')
        when '2'
          @embargo_release_date = (embargo_start_date_object + 1.year).strftime('%Y-%m-%d')
        when '3'
          @embargo_release_date = (embargo_start_date_object + 2.year).strftime('%Y-%m-%d')
        when '4'
          diss_sales_restriction_remove =
            nokogiri_xml.css("DISS_restriction>DISS_sales_restriction").first["remove"]
          sales_restriction_remove_date_object = Date.strptime(diss_sales_restriction_remove, "%m/%d/%Y")
          @embargo_release_date = sales_restriction_remove_date_object.strftime('%Y-%m-%d')
        end
      end
    end
  end
end
