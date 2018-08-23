require 'net/http'
module Sword
  module Adapters
    class HyacinthAdapter

      attr_reader :digital_object_data,
                  :dynamic_field_data,
                  :hyacinth_server_response,
                  :item_pid

      attr_accessor :abstract,
                    :asset_import_filepath,
                    :asset_parent_pid,
                    :doi,
                    :date_issued_start,
                    :degree,
                    :deposited_by,
                    :embargo_release_date,
                    :genre_uri,
                    :genre_value,
                    # fcd1, 28Jul18: Move following two attributes into initializer at a later date if feasible
                    :hyacinth_project,
                    :hyacinth_user,
                    # fcd1, 28Jul18: See above
                    :language_uri,
                    :language_value,
                    :license_uri,
                    :names,
                    :no_op_post,
                    :note_type,
                    :note_value,
                    :parent_publication,
                    :personal_names,
                    :subjects,
                    :title,
                    :type_of_resource,
                    :uri,
                    :use_and_reproduction_uri

      def initialize
        @dynamic_field_data = {}
        @names = []
        @subjects = []
        # following is usefule for testing. If set to true, Post
        # request won't be sent to server
        @no_op_post = false
      end

      def compose_internal_format_item
        @digital_object_data = {}
        @digital_object_data[:digital_object_type] = {string_key: 'item'}
        @digital_object_data[:project] = {string_key: @hyacinth_project}
        compose_dynamic_field_data
        @digital_object_data[:dynamic_field_data] = @dynamic_field_data
      end

      def ingest_item
        # just to be safe, reset response instance
        @hyacinth_server_response = nil
        payload = {}
        payload[:digital_object_data_json] = JSON.generate @digital_object_data
        # puts payload_json.inspect
        uri = URI(HYACINTH_CONFIG[:url])
        post_req = Net::HTTP::Post.new(uri)
        # post_req.set_form_data("digital_object_data_json" => data_json)
        post_req.set_form_data(payload)
        # puts post_req.body.inspect
        post_req.basic_auth(HYACINTH_CONFIG[:username],
                            HYACINTH_CONFIG[:password])
        unless @no_op_post
          @hyacinth_server_response = Net::HTTP.start(uri.hostname,
                                               uri.port,
                                               use_ssl: HYACINTH_CONFIG[:use_ssl]) { |http| http.request(post_req) }
        end
        # puts @hyacinth_response.inspect
        @item_pid = pid_last_ingest
        # @hyacinth_server_response
      end

      def compose_internal_format_asset(parent_pid,
                                        asset_import_filepath)
        @digital_object_data = {}
        @digital_object_data[:digital_object_type] = {string_key: 'asset'}
        @digital_object_data[:project] = {string_key: @hyacinth_project}
        @digital_object_data[:parent_digital_objects] = [{identifier: parent_pid}]
        @digital_object_data[:import_file] = compose_import_file_data asset_import_filepath
        # Rails.logger.info "!!!!!!!!!!!!!!!!!! import_file!!!!!!!!"
        # Rails.logger.info "#{digital_object_data[:import_file]}"
      end

      def ingest_asset(parent_pid,
                       document_filepath)
        asset_import_subdir = "swordtmp_#{parent_pid}"
        asset_import_subdir.gsub!(':','')
        # puts'*************************asset import dir***********************'
        # puts asset_import_subdir
        fullpath_asset_import_dir = File.join(HYACINTH_CONFIG[:upload_directory], asset_import_subdir)
        # puts fullpath_asset_import_dir
        FileUtils.mkdir_p(fullpath_asset_import_dir)
        FileUtils.cp(document_filepath,fullpath_asset_import_dir)
        asset_filename = File.basename(document_filepath)
        asset_import_filepath = File.join(asset_import_subdir,asset_filename)
        # puts asset_import_filepath
        # create the hyacinth internal format data
        compose_internal_format_asset(parent_pid,
                                      asset_import_filepath)
        # puts @digital_object_data
        # just to be safe, reset response instance
        @hyacinth_server_response = nil
        payload = {}
        payload[:digital_object_data_json] = JSON.generate @digital_object_data
        # puts payload_json.inspect
        uri = URI(HYACINTH_CONFIG[:url])
        post_req = Net::HTTP::Post.new(uri)
        # post_req.set_form_data("digital_object_data_json" => data_json)
        post_req.set_form_data(payload)
        # puts post_req.body.inspect
        post_req.basic_auth(HYACINTH_CONFIG[:username],
                            HYACINTH_CONFIG[:password])
        unless @no_op_post
          @hyacinth_server_response = Net::HTTP.start(uri.hostname,
                                               uri.port,
                                               use_ssl: HYACINTH_CONFIG[:use_ssl]) { |http| http.request(post_req) }
        end
        # puts @hyacinth_response.inspect
        @hyacinth_server_response
      end

      def last_ingest_successful?
        unless @hyacinth_server_response.nil?
          @hyacinth_server_response.body['success']
        else
          false
        end
      end

      def pid_last_ingest
        unless @hyacinth_server_response.nil?
          JSON.parse(@hyacinth_server_response.body)['pid']
        end
      end

      def http_code_sucess_2xx?
        return (Integer(@hyacinth_server_response.code)/100) == 2
      end

      # fcd1, 07/30/18: Remove private restricton to ease testing (for now?)
      # private
      def compose_dynamic_field_data
        # fcd1, 27Jul18: uncomment following calls as methods are updated for new scheme
        encode_abstract unless @abstract.nil?
        encode_date_issued unless @date_issued.nil?
        encode_degree unless @degree.nil?
        encode_deposited_by # this should always be set
        encode_embargo_release_date unless @embargo_release_date.nil?
        encode_genre unless @genre_uri.nil? and @genre_value.nil?
        encode_language unless @language_uri.nil? and @language_value.nil?
        encode_license unless @license_uri.nil?
        encode_names unless @names.empty?
        encode_note unless @note_value.nil?
        encode_parent_publication unless @parent_publication.nil?
        encode_subjects unless @subjects.empty?
        encode_title # should always be a title, can raise error if so
        encode_type_of_resource unless @type_of_resource.nil?
        encode_use_and_reproduction unless @use_and_reproduction_uri.nil?
      end

      def encode_abstract
        @dynamic_field_data[:abstract] = []
        @dynamic_field_data[:abstract] << { abstract_value: @abstract }
      end

      def encode_date_issued
        @dynamic_field_data[:date_issued] = []
        @dynamic_field_data[:date_issued] << { date_issued_start_value: @date_issued_start }
      end

      def encode_degree
        @dynamic_field_data[:degree] = []
        @dynamic_field_data[:degree] << { degree_name: @degree.name,
                                          degree_level: @degree.level,
                                          degree_discipline: @degree.discipline,
                                          degree_grantor: 'Columbia University' }
      end

      def encode_deposited_by
        @dynamic_field_data[:deposited_by] = []
        @dynamic_field_data[:deposited_by] << { deposited_by_value: @deposited_by }
      end

      def encode_embargo_release_date
        @dynamic_field_data[:embargo_release_date] = []
        @dynamic_field_data[:embargo_release_date] << { embargo_release_date_value: @embargo_release_date }
      end

      def encode_genre
        genre_data = { value: @genre_value,
                       uri: @genre_uri }
        @dynamic_field_data[:genre] = []
        @dynamic_field_data[:genre] << { genre_term: genre_data }
      end

      def encode_language
        language_data = { value: @language_value,
                          uri: @language_uri }
        @dynamic_field_data[:language] = []
        @dynamic_field_data[:language] << { language_term: language_data }
      end

      def encode_license
        license_data = { uri: @license_uri }
        @dynamic_field_data[:license] = []
        @dynamic_field_data[:license] << { license_term: license_data }
      end

      def encode_names
        @dynamic_field_data[:name] = []
        @names.each do |named_entity|
          case named_entity.type
          when 'corporate'
            set_corporate_name_and_originator_role named_entity
          when 'personal'
            case named_entity.role
            when 'author'
              set_personal_name_and_author_role named_entity
            when 'thesis_advisor'
              set_personal_name_and_advisor_role named_entity
            else
              # default to author? (check this)
              set_personal_name_and_advisor_role named_entity
            end
          end
        end
      end

      def encode_note
        @dynamic_field_data[:note] = []
        @dynamic_field_data[:note] << { note_value: @note_value }
        @dynamic_field_data[:note] << { note_type: @note_type } unless @note_type.nil?
      end

      def encode_parent_publication
        @dynamic_field_data[:parent_publication] = []
        unless @parent_publication.title.nil?
          title_data = []
          title_data << { parent_publication_title_non_sort_portion: nil,
                          parent_publication_title_sort_portion:  @parent_publication.title }
          parent_publication_data = { parent_publication_title: title_data }
        end
        parent_publication_data[:parent_publication_date_created_textual] =
          @parent_publication.publish_date unless @parent_publication.publish_date.nil?
        parent_publication_data[:parent_publication_volume] =
          @parent_publication.volume unless @parent_publication.volume.nil?
        parent_publication_data[:parent_publication_issue] =
          @parent_publication.issue unless @parent_publication.issue.nil?
        parent_publication_data[:parent_publication_page_start] =
          @parent_publication.start_page unless @parent_publication.start_page.nil?
        parent_publication_data[:parent_publication_doi] =
          @parent_publication.doi unless @parent_publication.doi.nil?
        @dynamic_field_data[:parent_publication] << parent_publication_data
      end

      # For now, don't encode non-sort portion. Can always add functionality later, though
      # need to come up with non-sort terms
      def encode_title
        @dynamic_field_data[:title] = []
        @dynamic_field_data[:title] << { title_non_sort_portion: nil,
                                         title_sort_portion:  @title }
      end

      def encode_subjects
        @dynamic_field_data[:subject_topic] = []
        @dynamic_field_data[:subject_geographic] = []

        # multiple subjects allowed, deposit_content.subjects is an array
        @subjects.each do |subject|
          # hash will return nil if key not present
          proquest_fast_mapping = PROQUEST_FAST_MAP[subject.downcase]
          if proquest_fast_mapping
            fast_subject proquest_fast_mapping
          else
            set_subject_topic subject
          end
        end
      end

      def encode_type_of_resource
        @dynamic_field_data[:type_of_resource] = []
        @dynamic_field_data[:type_of_resource] << { type_of_resource_value: @type_of_resource }
      end

      def set_corporate_name_and_originator_role corporate_entity
        corporate_name_data = { value: "#{corporate_entity.corporate_name}",
                                name_type: 'corporate' }
        name_role_data = []
        name_role_data << set_name_role(METADATA_VALUES[:name_role_originator_value],
                                        METADATA_VALUES[:name_role_originator_uri])
        @dynamic_field_data[:name] << { name_term: corporate_name_data,
                                        name_role: name_role_data }
      end

      def encode_use_and_reproduction
        use_and_reproduction_data = { uri: @use_and_reproduction_uri }
        @dynamic_field_data[:use_and_reproduction] = []
        @dynamic_field_data[:use_and_reproduction] << { use_and_reproduction_term: use_and_reproduction_data }
      end

      def set_personal_name_and_author_role author
        value_data = prep_name author
        personal_name_data = { value: value_data,
                               name_type: 'personal' }
        name_role_data = []
        name_role_data << set_name_role(METADATA_VALUES[:name_role_author_value],
                                        METADATA_VALUES[:name_role_author_uri])
        @dynamic_field_data[:name] << { name_term: personal_name_data,
                                        name_role: name_role_data }
      end
  
      def set_personal_name_and_advisor_role advisor
        value_data = prep_name advisor
        personal_name_data = { value: value_data,
                               name_type: 'personal' }
        name_role_data = []
        name_role_data << set_name_role(METADATA_VALUES[:name_role_thesis_advisor_value],
                                        METADATA_VALUES[:name_role_thesis_advisor_uri])
        @dynamic_field_data[:name] << { name_term: personal_name_data,
                                        name_role: name_role_data }
      end

      def set_name_role(name_role_value, name_role_uri = nil)
        name_role_term_data = { value:  name_role_value }
        name_role_term_data[:uri] = name_role_uri if name_role_uri
        { name_role_term: name_role_term_data }
      end

      def set_subject_topic(topic_value, topic_uri = nil)
        subject_topic_term_data = { value:  topic_value }
        subject_topic_term_data[:uri] = topic_uri if topic_uri
        @dynamic_field_data[:subject_topic] << { subject_topic_term: subject_topic_term_data }
      end

      def set_subject_geographic(geographic_value, geographic_uri = nil)
        subject_geographic_term_data = { value:  geographic_value }
        subject_geographic_term_data[:uri] = geographic_uri if geographic_uri
        @dynamic_field_data[:subject_geographic] << { subject_geographic_term: subject_geographic_term_data }
      end

      def compose_import_file_data(filepath)
        import_file_data = {}
        import_file_data[:import_path]=filepath
        import_file_data[:import_type]='upload_directory'
        import_file_data
      end

      def fast_subject proquest_fast_mapping
        # handle fast topic subjects
        proquest_fast_mapping[:topic].each do |fast_topic|
          set_subject_topic(fast_topic[:label],
                            fast_topic[:uri])
        end if proquest_fast_mapping[:topic]
        # handle fast geographic subjects
        proquest_fast_mapping[:geographic].each do |fast_geographic|
          set_subject_geographic(fast_geographic[:label],
                                 fast_geographic[:uri])
        end if proquest_fast_mapping[:geographic]
      end

      def prep_name person
        if person.full_name_naf_format.nil?
          # Add period to first_name and/or middle_name if name contains only one letter
          prepped_first_name = person.first_name.length == 1 ? person.first_name.slice(0,1) + "." :
                                 person.first_name unless person.first_name.nil?
          prepped_middle_name = person.middle_name.length == 1 ? person.middle_name.slice(0,1) + "." :
                                  person.middle_name unless person.middle_name.nil?
          value_data = "#{person.last_name}, #{prepped_first_name} #{prepped_middle_name}"
        else
          value_data = "#{person.full_name_naf_format}"
          # using lookahead, following catches all single letter names and puts
          # a period after them, except for the last one, which does not have
          # a trailing space
          value_data.gsub!( / (\w)(?= )/, ' \1.')
          # Following puts period on last initial, if needed
          value_data.gsub!( /( \w$)/, '\1.')
        end
        value_data
      end

    end
  end
end
