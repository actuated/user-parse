#!/bin/bash
# user-parse.sh
# 10/30/2015 by Ted R (http://github.com/actuated)
# Script to take an input list of names and email addresses, then convert them into unique, lowercase usernames
# Meant for OSINT results (names, emails, metadata, etc.).
# See user-enum-parse.sh for extracting usernames from sid2name/rpcclient/smb_enumusers. 
# Want to add a format? Update the usage, fn_ln_parse and check_format functions at the beginning of the script
# 10/31/2015 - Added support for domain\username and skipping comments marked by #
# 11/03/2015 - Changed comment check to be first character only, corrected outfile check
# 1/1/2016 - Aesthetic change

varDateCreated="10/30/2015"
varDateLastMod="1/1/2016"
varTempRandom=$(( ( RANDOM % 9999 ) + 1 ))
varTempFile="temp-user-parse-$varTempRandom.txt"
if [ -f $varTempFile ]; then rm $varTempFile; fi
varInFile="null"
varOutFile=""
varFormat="null"

# Function for displaying help/usage information
function usage
{
echo
echo "=====================[ username parser - Ted R (github: actuated) ]======================"
echo
echo "Script to parse an input file to unique, lowercase usernames."
echo "Intended to be used for public information gathering results."
echo "Lines can contain emails, domain\\username, or first and last names."
echo "First and last names will be converted to the format set by -f."
echo
echo "Created $varDateCreated, last modified $varDateLastMod."
echo
echo "=======================================[ syntax ]========================================"
echo
echo -e "Usage: \t./user-parse.sh -i [input file] -f [format] [-o [outout file]]"
echo -e "Ex: \t./user-parse.sh -i names.txt -f jsmith"
echo
echo "Required Parameters:"
echo
echo -e "\t -i [input file] \t Input file, must exist"
echo -e "\t -f [format] \t\t Output username format, must match format options below"
echo -e "\t\t jsmith"
echo -e "\t\t john.smith"
echo -e "\t\t john_smith"
echo -e "\t\t johns"
echo -e "\t\t johnsmith"
echo
echo "Optional:"
echo
echo -e "\t -o [output file] \t Optional output file, must not exist"
echo
echo "========================================[ info ]========================================="
echo
echo "Parsing Criteria:"
echo
echo -e "\t - These criteria appear in order."
echo -e "\t - Lines will be processed according to the first criteria they meet."
echo -e "\t - All strings will be converted to lowercase."
echo -e "\t - Apostraphes (') will be removed."
echo -e "\t - Lines that start with '#' will be skipped."
echo
echo -e "\t line contains '@' \t - Assumed to be an email address"
echo -e "\t\t\t\t - Will be broken into substrings delimited by '@'"
echo -e "\t\t\t\t - The first substring will be read as the username"
echo -e "\t\t\t\t * Lines must contain a substring before '@'"
echo -e "\t\t\t\t - Spaces will be removed"
echo
echo -e "\t line contains '\' \t - Assumed to be domain\\user"
echo -e "\t\t\t\t - Will be broken into substrings delimited by '\'"
echo -e "\t\t\t\t - The last substring will be read as the username"
echo -e "\t\t\t\t * Lines must contain a substring after the last '\\'"
echo -e "\t\t\t\t - Spaces will be removed"
echo
echo -e "\t line contains ',' \t - Will be broken into substrings delimited by ','"
echo -e "\t\t\t\t - The first substring will be read as the last name"
echo -e "\t\t\t\t - The second substring will beread as the first name"
echo -e "\t\t\t\t * Lines can only contain two substrings"
echo -e "\t\t\t\t - Spaces, periods and commas will be removed"
echo -e "\t\t\t\t - Results will be converted to the selected format"
echo
echo -e "\t line contains ' ' \t - Will be broken into substrings delimited by ' '"
echo -e "\t\t\t\t - The first substring will be read as the first name"
echo -e "\t\t\t\t - The second substring will be read as the last name"
echo -e "\t\t\t\t * Lines can only contain two substrings"
echo -e "\t\t\t\t - Periods will be removed"
echo -e "\t\t\t\t - Results will be converted to the selected format"
echo
echo -e "\t single substring \t - Assumed to already be a username"
echo -e "\t\t\t\t - Includes ',' delimited lines with only one substring"
echo -e "\t\t\t\t - Includes lines with no '@', '\\', or ' '"
echo
echo "Notes:"
echo
echo -e "\t - If script is stopped or fails, check for temp-user-parse-*.txt"
echo
exit
}

function fn_ln_parse
{
# Cut FI and LI from FN and LN
      varLI=$(echo "$varLN" | cut -c1)
      varFI=$(echo "$varFN" | cut -c1)
# Process based on selected name output format
      if [ "$varFormat" = "jsmith" ]; then
        varLineOut="$varFI$varLN"
      elif [ "$varFormat" = "john.smith" ]; then
        varLineOut="$varFN.$varLN"
      elif [ "$varFormat" = "john_smith" ]; then
        varLineOut="$varFN"_"$varLN"
      elif [ "$varFormat" = "johns" ]; then
        varLineOut="$varFN$varLI"
      elif [ "$varFormat" = "johnsmith" ]; then
        varLineOut="$varFN$varLN"
      fi
}

function check_format
{
if [ "$varFormat" != "jsmith" ] && [ "$varFormat" != "john.smith" ] && [ "$varFormat" != "john_smith" ] && [ "$varFormat" != "johns" ] && [ "$varFormat" != "johnsmith" ] ; then
  echo; echo "Error: Invalid format type supplied."; usage; fi
}

# Check input for necessary length
varTestInput=$(echo $1 $2 $3 $4 $5 $6 $7)
varTestInputForOutputOpt=$(echo $varTestInput | grep ".-o." )
varTestInputCount=$(echo $varTestInput | awk '{print NF}')

if [ "$1" = "-h" ]; then usage; fi

if [ "$varTestInputForOutputOpt" = "" ]; then
  if [ "$varTestInputCount" != "4" ]; then
    echo
    echo "Error: Input appears to be incomplete or incorrect."
    usage
  fi
else
  if [ "$varTestInputCount" != "6" ]; then
    echo
    echo "Error: Input appears to be incomplete or incorrect."
    usage
  fi
fi

# Check for options and parameters
while [ "$1" != "" ]; do
  case $1 in
    -i ) shift
         varInFile=$1
         if [ "$varInFile" = "" ]; then varInFile="null"; fi # Flag for error if no file name was given
         if [ ! -f "$varInFile" ]; then varInFile="existerror"; fi # Flag for error if input file does not exist
         ;;
    -f ) shift
         varFormat=$(echo $1 | tr "A-Z" "a-z")
         ;;
    -o ) shift
         varOutFile=$1
         if [ "$varOutFile" = "" ]; then varOutFile="nullerror"; fi # Flag for error if no file name was given
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
if [ "$varOutFile" = "exists" ]; then echo; echo "Error: Output file exists."; usage; fi
check_format

# Display parameters to user for confirmation before starting
echo
echo "=====================[ username parser - Ted R (github: actuated) ]======================"
echo
echo "Reading from $varInFile to convert first and last names to '$varFormat' format."
echo "Usernames will be retrieved from single strings, emails, and domain\\username."
echo "See usage/help information (-h) for parsing criteria."
if [ "$varOutFile" != "" ]; then echo; echo "Output will be written to $varOutFile."; fi
echo
read -p "Press Enter to continue..."

echo
echo "=====================================[ conversion ]======================================"
echo

# Process usernames to temp file
while read -r varLine; do
  varLineOut=""
  varLineFormat=""
  varConvLine=$(echo $varLine | tr 'A-Z' 'a-z' | tr -d \' ) # Convert case and remove (')
  varCheckComment=$(echo "$varConvLine" | cut -c1 | grep "^#" )
  varCheckEmail=$(echo "$varConvLine" | grep "@")
  varCheckSlash=$(echo "$varConvLine" | grep '\\')
  varCheckSpaceFields=$(echo "$varConvLine" | awk '{print NF}')
  varCheckCommaFields=$(echo "$varConvLine" | awk -F "," '{print NF}')
  varCheckSlashFields=$(echo "$varConvLine" | awk -F "\\" '{print NF}')

  if [ "$varCheckComment" != "" ]; then
    varLineOut="skipforcomment"
  fi

  if [ "$varCheckEmail" != "" ] && [ "$varLineOut" = "" ]; then
    varEmail=$(echo "$varConvLine" | awk -F "@" '{print $1}' | tr -d ' ')
    if [ "$varEmail" != "" ]; then
      varLineOut=$varEmail
      varLineFormat="extract (email)"
    fi
  fi

  if [ "$varCheckSlashFields" -gt "1" ] && [ "$varLineOut" = "" ]; then
    varDomUser=$(echo "$varConvLine" | awk -F "\\" '{print $NF}' | tr -d ' ')
    if [ "$varDomUser" != "" ]; then
      varLineOut=$varDomUser
      varLineFormat="extract (domain\\user)"
    fi
  fi

  if [ "$varCheckCommaFields" = "2" ] && [ "$varLineOut" = "" ]; then
    varLN=$(echo "$varConvLine" | awk -F "," '{print $1}' | tr -d ' ' | tr -d ',' | tr -d '.')
    varFN=$(echo "$varConvLine" | awk -F "," '{print $2}' | tr -d ' ' | tr -d ',' | tr -d '.')
    if [ "$varLN" != "" ] && [ "$varFN" != "" ]; then
      varLineFormat="convert (ln, fn)"
      fn_ln_parse
    fi
  fi

  if [ "$varCheckSpaceFields" = "2" ] && [ "$varLineOut" = "" ]; then
    varLN=$(echo "$varConvLine" | awk '{print $2}' | tr -d ' ' | tr -d ',' | tr -d '.')
    varFN=$(echo "$varConvLine" | awk '{print $1}' | tr -d ' ' | tr -d ',' | tr -d '.')
    if [ "$varLN" != "" ] && [ "$varFN" != "" ]; then
      varLineFormat="convert (fn ln)"
      fn_ln_parse
    fi
  fi

  if [ "$varCheckSpaceFields" = "1" ] && [ "$varCheckEmail" = "" ] && [ "$varLineOut" = "" ] && [ "$varCheckSlash" = "" ]; then
    if [ "$varCheckCommaFields" -lt "3" ]; then
      varLineOut=$(echo "$varConvLine" | tr -d ',')
      varLineFormat="single substring"
    fi
  fi

# Display conversion results
  if [ "$varLineOut" != "" ] && [ "$varLineOut" != "skipforcomment" ]; then
    echo "$(tput setaf 2)[+]$(tput sgr0) '$varLine' - $(tput setaf 4)$varLineFormat$(tput sgr0) - $(tput setaf 6)'$varLineOut'$(tput sgr0)"
    echo "$varLineOut" >> $varTempFile
  elif [ "$varLineOut" = "" ] && [ "$varLine" != "" ]; then
    echo "$(tput setaf 1)[-] $(tput setaf 3)'$varLine'$(tput setaf 1) - Unexpected number of substrings - $(tput setaf 1)skipping$(tput sgr0)"
  fi

done < $varInFile
echo

# Display results
echo "=======================================[ output ]========================================"
echo
cat $varTempFile | sort | uniq | tee $varOutFile
# Remove temp file
if [ -f $varTempFile ]; then rm $varTempFile; fi
echo
echo "========================================[ fin. ]========================================="
echo


