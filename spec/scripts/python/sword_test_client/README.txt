sword_test_client.py is an extremely barebones shell of a SWORD client used for
endpoint testing, including end-to-end testing.
This script uses the Request library (http://docs.python-requests.org/en/master/)
and therefore requires Python 3.

Sample run on Thu Oct 27 2016, certain info XXXXXXXXXX'out
Python 3.5.2 (default, Sep 10 2016, 08:21:44)
[GCC 5.4.0 20160609] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import sword
>>> sword.set_host('XXXXXXXX.library.columbia.edu')
>>> sword.set_credentials('DEPOSITOR_BASIC_AUTHENTICATION_USER_ID_GOES_HERE','DEPOSITOR_PASSWORD_GOES_HERE')
>>> sword.post_deposit_https('COLLECTION_SLUG_GOES_HERE','RELATIVE_PATH_FILENAME_OF_ZIP_FILES_GOES_HERE')
Port not set
<Response [200]>
>>>
