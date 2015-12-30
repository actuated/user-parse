#!/bin/bash
# user-enum-parse.sh
# 10/31/2015 by tedr@tracesecurity.com
# Script to take an input file from user enumeration tools and extract usernames
# 11/1/2015 Revised search expressions and total displays
# 11/1/2015 Added support for :-delim lines, rewrote grep searches to identify lines
# 11/3/2015 Noted that msf summary output from smb_lookupsid includes machine accts

varDateCreated="10/31/2015"
varDateLastMod="11/01/2015"
varTempRandom=$(( ( RANDOM % 9999 ) + 1 ))
varTempFile="temp-user-enum-parse-$varTempRandom.txt"
if [ -f $varTempFile ]; then rm $varTempFile; fi
varInFile="null"
varOutFile=""
varAddDom="n"

# Function for displaying help/usage information
function usage
{
echo
echo "====================[ User Enum Parser - by tedr@tracesecurity.com ]====================="
echo
echo "Created $varDateCreated - Last Modified $varDateLastMod"
echo
echo "Script to extract usernames from a file containing user enumeration results."
echo
echo "=======================================[ Syntax ]========================================"
echo
echo -e "Usage: \t./user-enum-parse.sh -i [input file] [-o [outout file]]"
echo -e "Ex: \t./user-enum-parse.sh -i results.txt"
echo
echo "Required Parameters:"
echo
echo -e "\t -i [input file] \t Input file, must exist"
echo
echo "Optional:"
echo
echo -e "\t -o [output file] \t Optional output file, must not exist"
echo
echo "========================================[ Info ]========================================="
echo
echo "Parsing Criteria:"
echo
echo -e "\t colon-delim \t - Ex: Administrator:500:[hash]:[hash]:"
echo -e "\t\t\t - Ex: root:x:0:0:[...]"
echo -e "\t\t\t - grep '^[[:graph:]]*\:.*\:.*\:'"
echo -e "\t\t\t - Catches colon-delimited files starting with strings"
echo -e "\t\t\t - Meant for SAM, passwd, and hash files"
echo -e "\t\t\t - Usernames found before first ':'"
echo -e
echo -e "\t msf summary \t - Ex: [*] 192.168.1.1 DOMAIN [ Administrator, Guest, etc ]"
echo -e "\t\t\t - See code for grep command"
echo -e "\t\t\t - Meant for the summary output from various metasploit modules"
echo -e "\t\t\t - Ex: smb_enumusers, smb_lookupsid"
echo -e "\t\t\t - Comma separated usernames are found inside the second '[]'"
echo -e "\t\t\t - The entire summary output should be one input file line"
echo
echo -e "\t rpcclient \t - Ex: user:[administrator] rid:[0x12a]"
echo -e "\t\t\t - grep '^user:.*..rid:.*.$'"
echo -e "\t\t\t - Usernames found between 'user:[' and '] rid:'"
echo -e "\t\t\t - Lines containing '\$' are ignored"
echo
echo -e "\t smb_lookupsid \t - Ex: [*] 192.168.1.1 USER=Administrator RID=500"
echo -e "\t\t\t - See code for grep command"
echo -e "\t\t\t - Meant for detailed lines of module output"
echo -e "\t\t\t - The comma-delim summary output will be parsed as 'msf summary'"
echo -e "\t\t\t - Usernames found between 'USER=' and ' RID='"
echo -e "\t\t\t - Lines containing '\$' are ignored"
echo
echo "Notes:"
echo
echo -e "\t - The counts in the Extraction terminal output are not limited to unique names"
echo -e "\t - If stopped or failed, check for temp-user-enum-parse-*.txt"
echo
echo "==========[ (c) 2015 - free for personal or commercial use with credit intact ]=========="
echo
exit
}

# Check for options and parameters
while [ "$1" != "" ]; do
  case $1 in
    -i ) shift
         varInFile=$1
         if [ "$varInFile" = "" ]; then varInFile="null"; fi # Flag for error if no file name was given
         if [ ! -f "$varInFile" ]; then varInFile="existerror"; fi # Flag for error if input file does not exist
         ;;
    -o ) shift
         varOutFile=$1
         if [ "$varOutFile" = "" ]; then varOutFile="nullerror"; fi # Flag for error if no file name was given
         if [ "$varOutFile" = "-d" ]; then varOutFile="nullerror"; fi # Flag for error if -d gets pulled as missing output file name
         if [ -f "$varOutFile" ]; then varOutFile="exists"; fi # Flag for error if output file exists
         ;;
    -h ) usage
         exit
         ;;
    * )  usage
         exit 1
  esac
  shift
done

# Check parameters for errors
if [ "$varInFile" = "null" ]; then echo; echo "Error: Input file was not set."; usage; fi
if [ "$varInFile" = "existerror" ]; then echo; echo "Error: Input file does not exist."; usage; fi
if [ "$varOutFile" = "nullerror" ]; then echo; echo "Error: Output was enabled but no file name was given."; usage; fi
if [ "$varOutFile" = "existerror" ]; then echo; echo "Error: Input file does not exist."; usage; fi

# Display parameters to user for confirmation before starting
echo
echo "====================[ User Enum Parser - by tedr@tracesecurity.com ]====================="
echo
echo "Reading from $varInFile for username enumeration results."
if [ "$varOutFile" != "" ]; then echo; echo "Output will be written to $varOutFile."; fi
echo
read -p "Press Enter to continue..."

echo
echo "=====================================[ Extraction ]======================================"
echo

# Process usernames to temp file

varCountRead=0
varCountFound=0
varCountS2N=0
varCountRPC=0
varCountMSF=0
varCountCDF=0

while read -r varLine; do
  varLineOut=""
  varTestS2N=""
  varTestRPC=""
  varTestMSF=""
  varTestCDF=""
  varTestS2N=$(echo "$varLine" | grep '^\[\*\][[:space:]][[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*[[:space:]]USER=[[:graph:]]*[[:space:]]RID=.*$')
  varTestRPC=$(echo "$varLine" | grep '^user:.*..rid:.*.$')
  varTestMSF=$(echo "$varLine" | grep '^\[\*\][[:space:]][[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*[[:space:]][[:graph:]]*[[:space:]]\[.*.]')
  varTestCDF=$(echo "$varLine" | grep '^[[:graph:]]*\:.*\:.*\:')

# If smb_lookupsid, convert tags before and after name to Z, then awk for the username in between them (preserves spaces)
  if [ "$varLineOut" = "" ] && [ "$varTestS2N" != "" ]; then
    varLineOut=$(echo "$varLine" | tr 'A-Z' 'a-z' | grep "user=" | grep -v '\$' | sed 's/user=/Z/g' | sed 's/ rid=/Z/g' | awk -F "Z" '{print $2}')
    if [ "$varLineOut" != "" ]; then
      echo "$varLineOut" >> $varTempFile
      let varCountS2N=varCountS2N+1
      let varCountFound=varCountFound+1
    fi
    let varCountRead=varCountRead+1
# If rpcclient, convert tags before and after name to Z, then awk for the username in between them (preserves spaces)
  elif [ "$varLineOut" = "" ] && [ "$varTestRPC" != "" ]; then
    varLineOut=$(echo "$varLine" | tr 'A-Z' 'a-z' | grep "user:\[" | grep -v '\$' | sed 's/user:\[/Z/g' | sed 's/\] rid:/Z/g' | awk -F "Z" '{print $2}')
    if [ "$varLineOut" != "" ]; then
      echo "$varLineOut" >> $varTempFile
      let varCountRPC=varCountRPC+1
      let varCountFound=varCountFound+1
    fi
    let varCountRead=varCountRead+1
# If metasploit summary output, awk out comma-delim usernames, print each username to the temp file
  elif [ "$varTestMSF" != "" ] && [ "$varLineOut" = "" ]; then
    varLine=$(echo $varLine | awk -F '[\[\]]' '{print $4 }' | tr -d ',' | tr 'A-Z' 'a-z' )
    for varLineOut in $varLine; do
       if [ "$varLineOut" != "" ]; then
         echo "$varLineOut" >> $varTempFile
         let varCountMSF=varCountMSF+1
         let varCountFound=varCountFound+1
       fi
       let varCountRead=varCountRead+1
    done
  elif [ "$varLineOut" = "" ] && [ "$varTestCDF" != "" ]; then
    varLineOut=$(echo "$varLine" | tr 'A-Z' 'a-z' | grep -v '\$' | awk -F ':' '{print $1}')
    if [ "$varLineOut" != "" ]; then
      echo "$varLineOut" >> $varTempFile
      let varCountCDF=varCountCDF+1
      let varCountFound=varCountFound+1
    fi
    let varCountRead=varCountRead+1    
  elif [ "$varLineOut" = "" ]; then
    let varCountRead=varCountRead+1
  fi

  varDispLine=$(echo "$varLine" | cut -c1-75)
  echo -ne "$varDispLine...                                                                       "\\r

done < $varInFile
varCountUniq=$( cat $varTempFile | grep -v '\$' | sort | uniq | wc -l)
echo -ne "$varCountFound Found ($varCountUniq Unique Non-Machine Accts) in $varCountRead Lines Read                                                       "\\r
echo
echo
echo -e "Colon-Delimited: $varCountCDF \tMSF Summary: $varCountMSF"
echo -e "RPC Client: $varCountRPC \t\tSMB_LookupSID: $varCountS2N"
echo
read -p "Press Enter to display results..."
echo
# Display results
echo "=======================================[ Output ]========================================"
echo
cat $varTempFile | grep -v '\$' | sort | uniq | tee $varOutFile
# Remove temp file
if [ -f $varTempFile ]; then rm $varTempFile; fi
echo
echo "========================================[ fin. ]========================================="
echo


