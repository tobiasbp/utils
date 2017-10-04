#!/bin/sh

# A script for uploading local PDFs to a WebDAV enabled server
# using the cadaver WebDAV client.
#
# http://www.webdav.org/cadaver/

# Cadaver reads credentials from ~/.netrc
# The file should contain these lines (Substitute login & pass):
# default
# login YOUR_LOGIN
# passwd YOUR_PASSWORD

NETRC=~/.netrc

# Look for pdfs to upload in this directory
SOURCE=/var/cadaver

# Upload pdf files to this location (A WebDAV enabled URL)
DESTINATION=https://webdav.example.com/some/dest/dir

# The directory where uploaded files will be moved to
ARCHIVE=$SOURCE/.ARCHIVE

# Path to cadaver binary
CADAVER=/usr/local/bin/cadaver


# Exit if users .netrc file is not found
if [ ! -r $NETRC ]; then
  echo "Error: Can not read file $NETRC" 
  exit 1
fi

# Exit if source is not a directory
if [ ! -d $SOURCE ]; then
  echo "Error: Source directory $SOURCE does not exist"
  exit 1
fi 

# Exit if archive directory does not exist
if [ ! -d $ARCHIVE ]; then
  echo "Error: Archive directory $ARCHIVE does not exist"
  exit 1
fi

#FIXME: Check for existance of cadaver binary
 
# Go to the dir holding the PDFs to upload. Cadaver will fail if you do not.
# The reason is, that cadaver will upload to the full path of the original.
cd $SOURCE

# Look for pdfs (Case insensitive) in current dir (Should be source dir)
for FILE in `find . -maxdepth 1 -type f -iname '*.pdf'`; do

  # Attempt to upload the file. Save the response from cadaver
  RESPONSE=`echo "put $FILE" | $CADAVER $DESTINATION` 

  # Store the number of lines in the cadaver response with the string "succeeded"
  SUCCESS=`echo $RESPONSE | grep -i succeeded | wc -l` 
  
  # A success if there was one line with the word "succeeded"
  if [ $SUCCESS == '1' ]; then
    # Move uploaded file to archive. Overwrites older file with same name if exists
    echo "File $FILE uploaded to $DESTINATION. Moving local copy to folder $ARCHIVE"
    mv -vf $FILE $ARCHIVE/ 
  else
    # Could not upload the file. Return the cadaver response for trouble shooting
    echo "Error: $RESPONSE"
  fi 
done 
