# mods_parser.rb (used by AC self deposits)
## mapping to Hyacinth metadata
Based on mods. All of the MODS elements listed in
the table below are children of a root `<mods:mods>`

|AC MODS|hyacinth field|
|---|---|
|`<mods:abstract>`|abstract|
|`<mods:titleInfo>`|title_sort_portion|
|`<mods:originInfo><mods:dateIssued encoding="w3cdtf">`|date_issued_start_value|
|`<mods:name type="personal" ID="UNI_GOES_HERE"><mods:namePart>`|name_term.value + name_term.name_type "personal"|
|*role for the above name is always set to `author`*|name_role|
|`<mods:note type="internal">`|note_value (*`note_type` always set to `internal`*)|
|<mods:relatedItem type="host"><mods:identifier type="doi">|parent_publication:parent_publication_doi|
|<mods:relatedItem type="host"><mods:identifier type="uri">|parent_publication:parent_publication_uri|

## Example of mets files
The following is a sample mets file (test file used by Academic Commons code)

mets.xml:

```
<?xml version="1.0"?>
<mets xmlns="http://www.loc.gov/METS/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink" xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-2.xsd">
  <metsHdr CREATEDATE="2018-08-09T19:33:54Z">
    <agent ROLE="CUSTODIAN" TYPE="ORGANIZATION">
      <name>Academic Commons, Columbia University</name>
    </agent>
  </metsHdr>
  <dmdSec ID="sword-mets-dmd-1">
    <mdWrap MDTYPE="MODS">
      <xmlData>
        <mods:mods>
          <mods:titleInfo>
            <mods:title>Test Deposit</mods:title>
          </mods:titleInfo>
          <mods:abstract>foobar</mods:abstract>
          <mods:originInfo>
            <mods:dateIssued encoding="w3cdtf">2018</mods:dateIssued>
          </mods:originInfo>
          <mods:relatedItem type="host">
            <mods:identifier type="uri">https://www.example.com</mods:identifier>
          </mods:relatedItem>
          <mods:name type="personal" ID="abc123">
            <mods:namePart>Doe, Jane</mods:namePart>
            <mods:role>
              <mods:roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/aut" authority="marcrelator">Author</mods:roleTerm>
            </mods:role>
          </mods:name>
          <mods:name type="personal">
            <mods:namePart>Doe, John</mods:namePart>
            <mods:role>
              <mods:roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/aut" authority="marcrelator">Author</mods:roleTerm>
            </mods:role>
          </mods:name>
          <mods:accessCondition type="use and reproduction" displayLabel="License" xlink:href="https://creativecommons.org/licenses/by/4.0/"></mods:accessCondition>
          <mods:note type="internal">This deposit is just for testing purposes.</mods:note>
          <mods:recordInfo>
            <mods:recordInfoNote>AC SWORD MODS v1.0</mods:recordInfoNote>
          </mods:recordInfo>
        </mods:mods>
      </xmlData>
    </mdwrap>
  </dmdSec>
  <fileSec>
    <fileGrp ID="sword-mets-fgrp-1" USE="CONTENT">
      <file GROUPID="sword-mets-fgid-0" ID="sword-mets-file-1" MIMETYPE="text/plain">
        <FLocat LOCTYPE="URL" xlink:href="test_file.txt"/>
      </file>
      <file GROUPID="sword-mets-fgid-1" ID="sword-mets-file-2" MIMETYPE="application/pdf">
        <FLocat LOCTYPE="URL" xlink:href="alice_in_wonderland.pdf"/>
      </file>
    </fileGrp>
  </fileSec>
  <structMap ID="sword-mets-struct-1" LABEL="structure" TYPE="LOGICAL">
    <div ID="sword-mets-div-1" DMDID="sword-mets-dmd-1" TYPE="SWORD Object">
      <div ID="sword-mets-div-2" TYPE="File"/>
      <fptr FILEID="sword-mets-file-1"/>
      <fptr FILEID="sword-mets-file-2"/>
    </div>
  </structMap>
</mets>
```
