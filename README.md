# CUL SWORD service
The CUL SWORD service can be used to deposit file(s) into Hyacinth. The file(s) are deposited into a SWORD collection by send a POST request to the associated URL, know as an endpoint.
BOGUS
## Setting up a new SWORD collection/endpoint (Admin)
* Create a new Collection on the SWORD server (_Currently in database via SWORD server GUI, but config file will be used in future version_)
* Associate a Depositor to the collection (_Currently in database via SWORD server GUI, but config file will be used in future version_). If desired, a new Depositor can be created (_Currently in database via SWORD server GUI, but config file will be used in future version_).

## Creating a new Depositor
_To be expanded once config setup is implemented_

# Client: initial setup
* Obtain the URL used as target of POST request from SWORD administrator
* Obtain the required credentials (username, password) from SWORD administrator

# Client: process to submit files
* Create mets.xml file with metadata and filenames (_include more info here or in new section below_)
* zip files, including mets file
* Deposit zip file using a POST request sent to the endpoint URL with credentials included in basic authentication.
