require 'net/http'
module Sword
  module Adapters
    class HyacinthAdapter

      attr_reader :asset_pids,
                  :digital_object_data,
                  :dynamic_field_data,
                  :hyacinth_server_response,
                  :item_pid

      attr_accessor :encoder_item,
                    :encoder_asset,
                    :abstract,
                    :asset_import_filepath,
                    :asset_parent_pid,
                    :corporate_names,
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
                    :no_op_post,
                    :notes,
                    :parent_publication,
                    :personal_names,
                    :subjects,
                    :title,
                    :type_of_resource,
                    :uri,
                    :use_and_reproduction_uri

      def initialize(encoder_class)
        @encoder_class = encoder_class
        @encoder_item = @encoder_class.new
        @encoder_asset = @encoder_class.new
        @asset_pids = []
        @corporate_names = []
        @dynamic_field_data = {}
        @notes = []
        @personal_names = []
        @subjects = []
        # following is usefule for testing. If set to true, Post
        # request won't be sent to server
        @no_op_post = false
      end

      def compose_internal_format_item
        @encoder_item.hyacinth_project = @hyacinth_project
        @digital_object_data = @encoder_item.compose_internal_format_item
      end

      def ingest_item
        # just to be safe, reset response instance
        @hyacinth_server_response = nil
        payload = {}
        payload[:digital_object_data_json] = JSON.generate @digital_object_data
        if HYACINTH_CONFIG[:store_digital_object_data]
          payload_file = File.join(HYACINTH_CONFIG[:payload_dir],"payload_#{Time.now.to_i}")
          Rails.logger.warn("Writing hyacinth payload file at #{payload_file}")
          File.open(payload_file, "w") { |file| file.write(JSON.pretty_generate @digital_object_data) }
        end
        # puts payload_json.inspect
        uri = URI(HYACINTH_CONFIG[:url])
        post_req = Net::HTTP::Post.new(uri)
        # post_req.set_form_data("digital_object_data_json" => data_json)
        post_req.set_form_data(payload)
        # puts post_req.body.inspect
        post_req.basic_auth(HYACINTH_CONFIG[:username],
                            HYACINTH_CONFIG[:password])
        unless @no_op_post
          Rails.logger.warn("ingest_item: Sending ingest request to Hyacinth") if HYACINTH_CONFIG[:log_ingest]
          @hyacinth_server_response = Net::HTTP.start(uri.hostname,
                                               uri.port,
                                               use_ssl: HYACINTH_CONFIG[:use_ssl]) { |http| http.request(post_req) }
          Rails.logger.warn("ingest_item: Completed ingest request to Hyacinth") if HYACINTH_CONFIG[:log_ingest]
        end
        # puts @hyacinth_response.inspect
        @item_pid = pid_last_ingest
        # @hyacinth_server_response
      end

      def compose_internal_format_asset(parent_pid,
                                        asset_import_filepath)
        @encoder_asset.hyacinth_project = @hyacinth_project
        @digital_object_data = @encoder_asset.compose_internal_format_asset(parent_pid,
                                                                            asset_import_filepath)
      end

      def setup_asset_import_filepath(parent_pid,
                                      document_filepath)
        asset_import_subdir = File.join(HYACINTH_CONFIG[:upload_subdir_prefix],"swordtmp_#{parent_pid}")
        asset_import_subdir.gsub!(':','')
        fullpath_asset_import_dir = File.join(HYACINTH_CONFIG[:upload_directory], asset_import_subdir)
        FileUtils.mkdir_p(fullpath_asset_import_dir)
        FileUtils.cp(document_filepath,fullpath_asset_import_dir)
        asset_filename = File.basename(document_filepath)
        File.join(asset_import_subdir,asset_filename)
      end

      def ingest_asset(parent_pid,
                       document_filepath)
        asset_import_filepath = setup_asset_import_filepath(parent_pid, document_filepath)
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
          Rails.logger.warn("ingest_asset: Sending ingest request to Hyacinth for #{File.basename(document_filepath)} (parent PID: #{parent_pid})") if HYACINTH_CONFIG[:log_ingest]
          @hyacinth_server_response = Net::HTTP.start(uri.hostname,
                                               uri.port,
                                               use_ssl: HYACINTH_CONFIG[:use_ssl]) { |http| http.request(post_req) }
          Rails.logger.warn("ingest_asset: Completed ingest request to Hyacinth") if HYACINTH_CONFIG[:log_ingest]
        end
        # puts @hyacinth_response.inspect
        @asset_pids << pid_last_ingest
        @hyacinth_server_response
      end

      def expected_and_retrieved_asset_pids_match?
        # retrieve item info from Hyacinth
        uri = URI("#{HYACINTH_CONFIG[:url]}/#{@item_pid}.json")
        get_req = Net::HTTP::Get.new(uri)
        get_req.basic_auth(HYACINTH_CONFIG[:username],
                            HYACINTH_CONFIG[:password])
        server_response =
          Net::HTTP.start(uri.hostname,
                          uri.port,
                          use_ssl: HYACINTH_CONFIG[:use_ssl]) { |http| http.request(get_req) }
        unless server_response.is_a?  Net::HTTPSuccess
          Rails.logger.warn("Item GET failure (Item PID: #{@item_pid}, HTTP code: #{server_response.code})")
          return false
        end
        retrieved_pids =
          JSON.parse(server_response.body)['ordered_child_digital_objects'].each.map { |pid_hash| pid_hash['pid'] }
        pids_match = Set.new(@asset_pids) == Set.new(retrieved_pids)
        unless pids_match
          Rails.logger.warn("Asset pids mismatch (expected: #{@asset_pids}, retrieved from Hyacinth Item: #{retrieved_pids}")
        end
        pids_match
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
    end
  end
end
