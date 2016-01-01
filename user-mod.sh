#!/bin/bash
# user-mod.sh
# 11/3/2015 by Ted R (http://github.com/actuated)
# Script to generate additions to possible usernames
# ie, f/m/l initials, appended numbers
# 1/1/2016 - Aesthetic change

varDateCreated="11/3/2015"
varDateLastMod="1/1/2016"
varTempRandom=$(( ( RANDOM % 9999 ) + 1 ))
varTempFile="temp-user-mod-$varTempRandom.txt"
if [ -f $varTempFile ]; then rm $varTempFile; fi
varInFile="null"
varOutFile="null"
varFormat="null"
varGMode="n"
varSMode="n"
varStatic="null"
varPos="4"

# Function for displaying help/usage information
function usage
{
echo
echo "====================[ username modifier - Ted R (github: actuated) ]====================="
echo
echo "Script used to add a string, numbers, or letters to possible usernames."
echo
echo "Created $varDateCreated, last modified $varDateLastMod."
echo
echo "=======================================[ syntax ]========================================"
echo
echo "./user-mod.sh -i [input file] [mode [parameter]] -p [position] [-o [outout file]]"
echo
echo
echo -e "-i [file] \t - Input file, must exist"
echo
echo -e "-s [string] \t - String mode"
echo -e "\t\t - 'String' will be added to each line"
echo
echo -e "-g [format] \t - Generator mode"
echo -e "\t\t - Add letters a-z or numbers to each line"
echo -e "\tabc \t - Format for letters a-z"
echo -e "\tn \t - Format for numbers 0-9"
echo -e "\t\t - Can be used 1-4 times (ex: -g n / -g nnnn)"
echo
echo -e "-p [value] \t - Position to insert new text"
echo -e "\t1\t - Add text to the beginning of each line"
echo -e "\t2\t - Add text to the middle of each line*"
echo -e "\t3\t - Add text to the end of each line"
echo
echo -e "-o [file] \t - Output file, must not exist"
echo
echo "========================================[ info ]========================================="
echo
echo "- For -p 1 and 3, each line of the input file will be read as an input string."
echo "- For -p 2, each line of the input file should contain two space-delimited substrings."
echo "  - These substrings would appear on either side of the inserted string."
echo "- One mode, -s or -g, must be specified."
echo "  - For -s [string], the specified string will be added to each input file string."
echo "    - '~' can be used to insert your input file lines in between two substrings."
echo "    - Ex: -s first~third"
echo "    - '~' can only be used once."
echo "  - For -g [format], letters or numbers will be generated to add to each string."
echo "    - abc = letters a-z."
echo "    - n = numbers 0-9, can be repeated 1-4 times (n, nn, nnn, nnnn)."
echo "- Position (-p) controls where the inserted or generated text will be added to the input."
echo "  - 1 = prepended to each input string."
echo "  - 2 = inserted in between two space-delimited input substrings."
echo "  - 3 = appended to the end of each input string."
echo "  - -p is not required when using '~' with -s."
echo "- An output file is required, given the bulk nature of this script."
echo "- If the script is stopped or fails, check for temp-user-mod-*.txt."
echo "- A line might be skipped if (1) if is blank, (2) it starts with a '#', or (3) you are"
echo "  using -p 2 with lines that do not contain two space-delimited substrings."
echo
echo "Usage Scenarios:"
echo
echo "Employee IDs - You have a list of 'jsmith'-format possible usernames, but the target"
echo "  adds a 4-digit employee ID to the end of each username."
echo "  - Make your input file the list of jsmith-format names"
echo "  - Run: ./user-mod.sh -i input.txt -g nnnn -p 3 -o output.txt"
echo "  - Results: 'jsmith0000 - jsmith9999'"
echo
echo "Middle Initials - You have a list of first and last names, but the target uses the"
echo "  username format john.x.smith."
echo "  - Make your input file the list of space-delimited names (ex: john. .smith)"
echo "  - Run: ./user-mod.sh -i input.txt -g abc -p 2 -o output.txt"
echo "  - Results: 'john.a.smith - john.z.smith'"
echo
echo "Admin Accounts - You have a list of user 'jsmith' usernames, and the target has"
echo "  separate 'admin-jsmith' accounts for privileged users."
echo "  - Make your input file the list of jsmith-format names"
echo "  - Run: ./user-mod.sh -i input.txt -s admin- -p 1 -o output.txt"
echo "  - Results: 'admin-jsmith', 'admin-x', where x is any other line of the input"
echo
exit
}

function check_mask
{
if [ "$varGMode" = "y" ] && [ "$varFormat" != "abc" ] && [ "$varFormat" != "n" ] && [ "$varFormat" != "nn" ] && [ "$varFormat" != "nnn" ] && [ "$varFormat" != "nnnn" ] ; then
  echo; echo "Error: Invalid format type supplied (abc, n, nn, nnn, or nnnn)."; usage; fi
}

# Check input for necessary length
#varTestInput=$(echo "$1 $2 $3 $4 $5 $6 $7 $8 $9" | awk '{print NF}')
#if [ "$varTestInput" != "8" ]; then
#  echo
#  echo "Error: Input appears to be incomplete or incorrect."
#  usage
#fi

# Check for options and parameters
while [ "$1" != "" ]; do
  case $1 in
    -i ) shift
         varInFile=$1
         if [ "$varInFile" = "" ]; then varInFile="null"; fi # Flag for error if no file name was given
         if [ ! -f "$varInFile" ]; then varInFile="existerror"; fi # Flag for error if input file does not exist
         ;;
    -s ) shift
         varSMode="y"
         varStatic=$1
         if [ "$varStatic" = "" ]; then varStatic="null"; fi # Flag for error if no static string was given
         ;;
    -g ) shift
         varGMode="y"
         varFormat=$(echo "$1" | tr 'A-Z' 'a-z')
         if [ "$varFormat" = "" ]; then varFormat="null"; fi # Flag for error if no generate format was given
         ;;
    -p ) shift
         varPos=$1
         if [ "$varPos" != "1" ] && [ "$varPos" != "2" ] && [ "$varPos" != "3" ]; then varPos="4"; fi # Flag for error on invalid position
         ;;
    -o ) shift
         varOutFile=$1
         if [ "$varOutFile" = "" ]; then varOutFile="null"; fi # Flag for error if no file name was given
         if [ -f "$varOutFile" ]; then varOutFile="existerror"; fi # Flag for error if output file exists
         ;;
    -h ) usage
         exit
         ;;
    * )  usage
         exit 1
  esac
  shift
done

varCheckStringWrap=$(echo "$varStatic" | grep '\~')
if [ "$varCheckStringWrap" != "" ]; then varPos=0; fi

# Check parameters for errors
if [ "$varInFile" = "null" ]; then echo; echo "Error: Input file was not set."; usage; fi
if [ "$varInFile" = "existerror" ]; then echo; echo "Error: Input file does not exist."; usage; fi
if [ "$varOutFile" = "null" ]; then echo; echo "Error: Output was enabled but no file name was given."; usage; fi
if [ "$varOutFile" = "existerror" ]; then echo; echo "Error: Output file already exists."; usage; fi
if [ "$varPos" -gt "3" ]; then echo; echo "Error: Position (-p) was not set to 1, 2 or 3."; usage; fi
if [ "$varSMode" = "y" ] && [ "$varGMode" = "y" ]; then echo; echo "Error: Both -s and -g were provided."; usage; fi
if [ "$varSMode" = "n" ] && [ "$varGMode" = "n" ]; then echo; echo "Error: No mode (-s or -g) was provded."; usage; fi
if [ "$varSMode" = "y" ] && [ "$varStatic" = "null" ]; then echo; echo "Error: -s was used with no string provided."; usage; fi
if [ "$varGMode" = "y" ] && [ "$varFormat" = "null" ]; then echo; echo "Error: -g was used with no format provided (abc, n, nn, nnn, nnnn)."; usage; fi
check_mask

# Display parameters to user for confirmation before starting
echo
echo "====================[ username modifier - Ted R (github: actuated) ]====================="
echo
if [ "$varSMode" = "y" ]; then
  if [ "$varPos" = "0" ]; then echo "Inserting lines from $varInFile into '$varStatic'."; fi
  if [ "$varPos" = "1" ]; then echo "Prepending each line of $varInFile with '$varStatic'."; fi
  if [ "$varPos" = "2" ]; then echo "Inserting '$varStatic' into each space-delimited line of $varInFile."; fi
  if [ "$varPos" = "3" ]; then echo "Appending '$varStatic' to the end of each line of $varInFile."; fi
fi
if [ "$varGMode" = "y" ]; then
  if [ "$varFormat" = "abc" ]; then
    if [ "$varPos" = "1" ]; then echo "Generating letters a-z to prepend each line of $varInFile."; fi
    if [ "$varPos" = "2" ]; then echo "Inserting letters a-z into each space-delimited line of $varInFile."; fi
    if [ "$varPos" = "3" ]; then echo "Appending letters a-z to the end of each line of $varInFile."; fi
  else
    if [ "$varPos" = "1" ]; then echo "Generating numbers 0-9 ($varFormat) to prepend each line of $varInFile."; fi
    if [ "$varPos" = "2" ]; then echo "Inserting numbers 0-9 ($varFormat) into each space-delimited line of $varInFile."; fi
    if [ "$varPos" = "3" ]; then echo "Appending numbers 0-9 ($varFormat) to the end of each line of $varInFile."; fi
  fi
fi
echo
echo "Output will be written to $varOutFile."
echo
read -p "Press Enter to continue..."

echo
echo "====================================[ modification ]====================================="
echo

# Process usernames to temp file
varCountLine=0
varCountCreated=0
varCountSkipped=0
while read -r varLine; do
varLineOut=""
varSkip="n"
varCheckComment=$(echo "$varLine" | grep '^\#')
varCheckFields=$(echo "$varLine" | awk '{print NF}')

# Check for line issues
if [ "$varLine" = "" ]; then varSkip="y"; let varCountSkipped=varCountSkipped+1; fi
if [ "$varSkip" = "n" ] && [ "$varCheckComment" != "" ]; then varSkip="y"; let varCountSkipped=varCountSkipped+1; fi
if [ "$varSkip" = "n" ] && [ "$varPos" = "2" ] && [ "$varCheckFields" != "2" ]; then varSkip="y"; let varCountSkipped=varCountSkipped+1; fi

if [ "$varSMode" = "y" ] && [ "$varSkip" = "n" ]; then
  if [ "$varPos" = "0" ]; then
    varCountWrap=$(echo "$varStatic" | awk -F '\~' '{print NF}')
    if [ "$varCountWrap" = "2" ]; then
      varLineA=$(echo "$varStatic" | awk -F '\~' '{print $1}')
      varLineB=$(echo "$varStatic" | awk -F '\~' '{print $2}')
      varLineOut="$varLineA$varLine$varLineB"
      echo "$varLineOut" >> $varTempFile
      echo -ne "Created $varLineOut...                                                           "\\r
      let varCountCreated=varCountCreated+1
    fi
  fi
  if [ "$varPos" = "1" ]; then 
    varLineOut="$varStatic$varLine"
    echo "$varLineOut" >> $varTempFile
    echo -ne "Created $varLineOut...                                                           "\\r
    let varCountCreated=varCountCreated+1
  fi
  if [ "$varPos" = "2" ]; then 
    varLineA=$(echo "$varLine" | awk '{print $1}')
    varLineB=$(echo "$varLine" | awk '{print $2}')
    varLineOut="$varLineA$varStatic$varLineB"
    echo "$varLineOut" >> $varTempFile
    echo -ne "Created $varLineOut...                                                           "\\r
    let varCountCreated=varCountCreated+1
  fi
  if [ "$varPos" = "3" ]; then 
    varLineOut="$varLine$varStatic"
    echo "$varLineOut" >> $varTempFile
    echo -ne "Created $varLineOut...                                                           "\\r
    let varCountCreated=varCountCreated+1
  fi
fi

if [ "$varGMode" = "y" ] && [ "$varSkip" = "n" ]; then
  if [ "$varFormat" = "abc" ]; then
    for varABC in {a..z}; do
      if [ "$varPos" = "1" ]; then varLineOut="$varABC$varLine"; fi
      if [ "$varPos" = "2" ]; then
        varLineA=$(echo "$varLine" | awk '{print $1}')
        varLineB=$(echo "$varLine" | awk '{print $2}')
        varLineOut="$varLineA$varABC$varLineB"  
      fi
      if [ "$varPos" = "3" ]; then varLineOut="$varLine$varABC"; fi
      echo "$varLineOut" >> $varTempFile
      echo -ne "Created $varLineOut...                                                           "\\r
      let varCountCreated=varCountCreated+1
    done
  elif [ "$varSkip" = "n" ] && [ "$varFormat" = "n" ]; then
    for varN in {0..9}; do
      if [ "$varPos" = "1" ]; then varLineOut="$varN$varLine"; fi
      if [ "$varPos" = "2" ]; then
        varLineA=$(echo "$varLine" | awk '{print $1}')
        varLineB=$(echo "$varLine" | awk '{print $2}')
        varLineOut="$varLineA$varN$varLineB"  
      fi
      if [ "$varPos" = "3" ]; then varLineOut="$varLine$varN"; fi
      echo "$varLineOut" >> $varTempFile
      echo -ne "Created $varLineOut...                                                           "\\r
      let varCountCreated=varCountCreated+1
    done
  elif [ "$varSkip" = "n" ] && [ "$varFormat" = "nn" ]; then
    for varN in {00..99}; do
      if [ "$varPos" = "1" ]; then varLineOut="$varN$varLine"; fi
      if [ "$varPos" = "2" ]; then
        varLineA=$(echo "$varLine" | awk '{print $1}')
        varLineB=$(echo "$varLine" | awk '{print $2}')
        varLineOut="$varLineA$varN$varLineB"  
      fi
      if [ "$varPos" = "3" ]; then varLineOut="$varLine$varN"; fi
      echo "$varLineOut" >> $varTempFile
      echo -ne "Created $varLineOut...                                                           "\\r
      let varCountCreated=varCountCreated+1
    done
  elif [ "$varSkip" = "n" ] && [ "$varFormat" = "nnn" ]; then
    for varN in {000..999}; do
      if [ "$varPos" = "1" ]; then varLineOut="$varN$varLine"; fi
      if [ "$varPos" = "2" ]; then
        varLineA=$(echo "$varLine" | awk '{print $1}')
        varLineB=$(echo "$varLine" | awk '{print $2}')
        varLineOut="$varLineA$varN$varLineB"  
      fi
      if [ "$varPos" = "3" ]; then varLineOut="$varLine$varN"; fi
      echo "$varLineOut" >> $varTempFile
      echo -ne "Created $varLineOut...                                                           "\\r
      let varCountCreated=varCountCreated+1
    done
  elif [ "$varSkip" = "n" ] && [ "$varFormat" = "nnnn" ]; then
    for varN in {0000..9999}; do
      if [ "$varPos" = "1" ]; then varLineOut="$varN$varLine"; fi
      if [ "$varPos" = "2" ]; then
        varLineA=$(echo "$varLine" | awk '{print $1}')
        varLineB=$(echo "$varLine" | awk '{print $2}')
        varLineOut="$varLineA$varN$varLineB"  
      fi
      if [ "$varPos" = "3" ]; then varLineOut="$varLine$varN"; fi
      echo "$varLineOut" >> $varTempFile
      echo -ne "Created $varLineOut...                                                           "\\r
      let varCountCreated=varCountCreated+1
    done
  fi
fi

  let varCountLine=varCountLine+1
done < $varInFile

let varLinesUsed=varCountLine-varCountSkipped
echo -ne "Created $varCountCreated from $varLinesUsed Lines ($varCountSkipped Skipped of $varCountLine Lines)."
echo; echo
read -p "Press Enter to display results..."
echo

# Display results
echo "=======================================[ output ]========================================"
echo
if [ -f $varTempFile ]; then
  cat $varTempFile | sort | uniq > $varOutFile
  varOutCount=$(wc -l < $varOutFile)
  if [ "$varOutCount" -gt "10" ]; then
    echo "Top 10 Lines of $varOutFile:"
    echo
    head $varOutFile
    echo "... cont'd..."
  else
    cat $varOutFile
  fi
  
  if [ -f $varTempFile ]; then rm $varTempFile; fi
else
  echo "No results..."
fi
echo
echo "========================================[ fin. ]========================================="
echo


