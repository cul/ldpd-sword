require 'builder'

module Sword::Utils::Sword
  def self.collection_info_for_service_document(collection_slug)
    info = HashWithIndifferentAccess.new
    info[:atom_title] = COLLECTIONS[:slug][collection_slug][:atom_title]
    info[:slug] = collection_slug
    info[:mime_types] = nil
    info[:sword_package_types] = nil
    info[:abstract] = nil
    info[:mediation_enabled] = false
    info
  end

  def self.pull_credentials(request)
    authorization = String.new(request.headers["Authorization"].to_s)
    if(authorization.include? 'Basic ')
      authorization['Basic '] = ''
      authorization = Base64.decode64(authorization)
      credentials = authorization.split(":")
      [credentials[0] , credentials[1]]
    end
  end

  def self.create_deposit(depositor_user_id,
                     collection_slug,
                     documents_to_deposit,
                     title,
                     item_pid,
                     asset_pids,
                     ingest_confirmed,
                     content_path)
    deposit = Deposit.new
    deposit.depositor_user_id = depositor_user_id
    deposit.collection_slug = collection_slug
    deposit.deposit_files = documents_to_deposit
    deposit.title = title.truncate_words(20).truncate(200, omission: '')
    deposit.item_in_hyacinth = item_pid
    deposit.asset_pids = asset_pids
    deposit.ingest_confirmed = ingest_confirmed
    deposit.content_path = content_path
    deposit.save
    deposit
  end

  def self.service_document_content
    content = HashWithIndifferentAccess.new
    # For site-specific values, read from the config file:
    content[:sword_version] = SWORD_CONFIG[:service_document][:sword_version]
    content[:sword_verbose] = SWORD_CONFIG[:service_document][:sword_verbose]
    # content[:http_host] = request.env["HTTP_HOST"]
    content[:collections] = []
    COLLECTIONS[:slug].keys.each do |collection_slug|
      if COLLECTIONS[:slug][collection_slug][:depositors].include? @depositor_user_id
        content[:collections] << view_context.collection_info_for_service_document(collection_slug)
      end
    end
    content
  end

  def self.service_document_xml(content)
    xml = Builder::XmlMarkup.new( :indent => 2 )
    xml.instruct! :xml, :encoding => "utf-8"
    xml.tag!("service",
              {"xmlns"=>"http://www.w3.org/2007/app",
               "xmlns:atom" => "http://www.w3.org/2005/Atom",
               "xmlns:sword" => "http://purl.org/net/sword/",
               "xmlns:dcterms" => "http://purl.org/dc/terms/"}) do |service|

      service.tag!("sword:version", content[:sword_version])
      service.tag!("sword:verbose", content["sword_verbose"])
      service.tag!("sword:noOp", SWORD_CONFIG[:service_document][:sword_no_op])

      service.workspace do |workspace|
        workspace.tag!("atom:title", SWORD_CONFIG[:service_document][:workspace_atom_title])
        content[:collections].each do |collection_info|
          workspace.tag!("collection", {"href"=> "https://" + content[:http_host] + "/sword/deposit/" + collection_info[:slug]}) do |collection|
            collection.tag!("atom:title", collection_info[:atom_title])
            collection.tag!("dcterms:abstract", collection_info[:abstract]) unless collection_info[:abstract].blank?
            unless collection_info[:mime_types].blank?
              collection_info[:mime_types].each do |content_type|
                collection.accept content_type
              end
            else
              SWORD_CONFIG[:service_document][:default_accept_mime_types].each do |content_type|
                collection.accept content_type
              end
            end
            unless collection_info[:sword_package_types].blank?
              collection_info[:sword_package_types].each do |packaging_accepted|
                collection.tag!("sword:acceptPackaging", {"q"=>"1.0"}, packaging_accepted)
              end
            else
              SWORD_CONFIG[:service_document][:default_accept_packaging].each do |packaging_accepted|
                collection.tag!("sword:acceptPackaging", {"q"=>"1.0"}, packaging_accepted)
              end
            end
            collection.tag!("sword:mediation", collection_info[:mediation_enabled])
          end
        end
      end
    end
  end
end
