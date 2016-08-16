require 'builder'
module SwordHelper
  def service_document_xml(content, http_host)

    xml = Builder::XmlMarkup.new( :indent => 2 )
    xml.instruct! :xml, :encoding => "utf-8"
    xml.tag!("service", 
              {"xmlns"=>"http://www.w3.org/2007/app", 
               "xmlns:atom" => "http://www.w3.org/2005/Atom",
               "xmlns:sword" => "http://purl.org/net/sword/",
               "xmlns:dcterms" => "http://purl.org/dc/terms/"}) do |service|
  
      service.tag!("sword:version", content[:sword_version]) 
      service.tag!("sword:verbose", content["sword_verbose"])
      service.tag!("sword:noOp", content["sword_noOp"])
  
      service.workspace do |workspace|
        workspace.tag!("atom:title", "Academic Commons - SWORD Service")
        content[:collections].each do |collection_info|
          puts collection_info.inspect
          workspace.tag!("collection", {"href"=> "http://" + http_host + "/sword/deposit/" + collection_info[:slug]}) do |collection|
            collection.tag!("atom:title", content["atom_title"])
            collection.tag!("dcterms:abstract", content["dcterms_abstract"])
            
            content["sword_content_types_supported"].each do |content_type|
              collection.accept content_type 
            end 
            
            content["sword_packaging_accepted"].each do |packaging_accepted|
              collection.tag!("sword:acceptPackaging", {"q"=>"1.0"}, packaging_accepted)
            end 
          
            collection.tag!("sword:mediation", content["sword_mediation"])
          end 
        end
   
      end
    end
  end
end
