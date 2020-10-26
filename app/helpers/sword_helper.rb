require 'builder'
module SwordHelper
  def service_document_xml(content)

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
