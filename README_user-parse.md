# user-parse.sh
Public information gathering might provide details like first and last names for employees, or email addresses. This shell script will let you take an input file containing that information, check each line for different formats to find possible usernames. Lines with first or last names will be converted based on the specified mask.

## Usage
```
./user-enum-parse.sh -i [inputfilename] -f [format] [-o [outputfilename]]
```

* **-i [filename]** specifies the input file, and is required. Each line of the input file will be checked against the parsing criteria described below.
* **-f [format]** specifies the mask that will be used when converting first and last names to possible usernames. Supported [format] values are:
  - **jsmith**
  - **john.smith**
  - **john_smith**
  - **johns**
  - **johnsmith**
* **-o [filename]** specifies an output file, which is not required.

## Parsing Criteria
Each line of the input file will be checked for the following formats. These formats appear in the order in which they are identified. Lines starting with '#' are skipped. Apostraphes (') are removed. Usernames are converted to lowercase, and output is sorted and limited to unique values.

* Line contains '@'
  - Assumed to be an email address.
  - The line will be broken into substrings delimited by '@'.
  - The first substring will be read as the username.
  - Lines must contain a substring before '@'.
  - Spaces will be removed.
* Line contains '\'
  - Assumed to be domain\username.
  - The line will be broken into substrings delimited by '\'.
  - The last substring will be read as the username.
  - Lines must contain a substring after the last '\'.
  - Spaces will be removed.
* Line contains ','
  - Assumed to be "Lastname, Firstname".
  - The line will be broken into substrings delimited by ','.
  - The first substring will be read as the last name.
  - The second substring will be read as the first name.
  - Lines can only contain two substrings.
  - Spaces, periods, and commas will be removed.
  - Names will be converted based on the selected format.
* Line contains ' '
  - Assumed to be "Firstname Lastname"
  - The line will be broken into substrings delimited by ' '.
  - The first substring will be read as the first name.
  - The second subsstring will be read as the last name.
  - Lines can only contain two substrings.
  - Periods will be removed.
  - Names will be converted based on the selected format.
* Line is not delimited by any of the above
  - Assumed to already be a username.
  - Includes ',' delimited lines with only one substring.
  - Includes lines with no '@', '\', or ' '.



## Example Input File
```
john smith
doe, jane
poe, edgar allan
three spaced names
@domain.com

name@
email@domain.com
domain\username
domain\\username
asmith
# Commented out
```

## Example Run
```
# ./user-parse.sh -i test.txt -f john_smith

======================[ Username Parser - tedr@tracesecurity.com ]=======================

Reading from test.txt to convert first and last names to 'john_smith' format.
Usernames will be retrieved from single strings, emails, and domain\username.
See usage/help information (-h) for parsing criteria.

Press Enter to continue...

=====================================[ Conversion ]======================================

[+] 'john smith' - convert (fn ln) - 'john_smith'
[+] 'doe, jane' - convert (ln, fn) - 'jane_doe'
[+] 'poe, edgar allan' - convert (ln, fn) - 'edgarallan_poe'
[-] 'three spaced names' - Unexpected number of substrings - skipping
[-] '@domain.com' - Unexpected number of substrings - skipping
[+] 'name@' - extract (email) - 'name'
[+] 'email@domain.com' - extract (email) - 'email'
[+] 'domain\username' - extract (domain\user) - 'username'
[+] 'domain\\username' - extract (domain\user) - 'username'
[+] 'asmith' - single substring - 'asmith'

=======================================[ Output ]========================================

asmith
edgarallan_poe
email
jane_doe
john_smith
name
username

========================================[ fin. ]=========================================

```
