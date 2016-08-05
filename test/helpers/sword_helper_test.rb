require 'test_helper'
class SwordHelperTest < ActionView::TestCase
  include ActionDispatch::TestProcess
  # puts request.env['HTTP_HOST']
  test "call servicedocument_xml" do
    test_http_host = 'example.com'
    test_info = {}
    # following is partly based on the values in sword.yml from hypatia-new
    test_info['sword_verbose'] = 'false'
    test_info['sword_verbose'] = 'false'
    test_info['collection'] = 'Test Collection'
    test_info['atom_title'] = 'Test Title'
    test_info['dcterms_abstract'] = 'Test DC Terms abstract'
    test_info['sword_content_types_supported'] = ['http://support-test-package-one', 'http://support-test-package-two']
    test_info['sword_packaging_accepted'] = ['application/zip']
    test_info['sword_mediation'] = 'false'
    # puts servicedocument_xml(test_info,test_http_host)
    servicedocument_xml(test_info,test_http_host)
  end
end
