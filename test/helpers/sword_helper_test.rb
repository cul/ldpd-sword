require 'test_helper'
class SwordHelperTest < ActionView::TestCase
  include ActionDispatch::TestProcess

  test "call servicedocument_xml" do
    expected_xml = fixture_file('service_document.xml')
    content = HashWithIndifferentAccess.new
    content[:sword_version] = SWORD_CONFIG[:service_document][:sword_version]
    content[:sword_verbose] = SWORD_CONFIG[:service_document][:sword_verbose]
    content[:http_host] = 'example.com'
    content[:collections] = []
    sample_info = HashWithIndifferentAccess.new
    sample_info[:atom_title] = 'Atom Title of First Test Collection'
    sample_info[:slug] = 'first-test-collection'
    sample_info[:mime_types] = ['foo_mime_type','bar_mime_type']
    sample_info[:sword_package_types] = ['foo_package_type','bar_package_type']
    sample_info[:abstract] = 'Collection Abstract'
    sample_info[:mediation_enabled] = 'false'
    content[:collections] << sample_info
    actual_xml = service_document_xml content
    assert_equal expected_xml, actual_xml
  end

  test "call servicedocument_xml, use defaults for accept (mime types) and sword package types" do
    expected_xml = fixture_file('service_document_with_defaults.xml')
    content = HashWithIndifferentAccess.new
    content[:sword_version] = SWORD_CONFIG[:service_document][:sword_version]
    content[:sword_verbose] = SWORD_CONFIG[:service_document][:sword_verbose]
    content[:http_host] = 'example.com'
    content[:collections] = []
    sample_info = HashWithIndifferentAccess.new
    sample_info[:mime_types] = []
    sample_info[:sword_package_types] = []
    sample_info[:atom_title] = 'Atom Title of First Test Collection'
    sample_info[:slug] = 'first-test-collection'
    sample_info[:abstract] = 'Collection Abstract'
    sample_info[:mediation_enabled] = 'false'
    content[:collections] << sample_info
    actual_xml = service_document_xml content
    assert_equal expected_xml, actual_xml
  end

end
