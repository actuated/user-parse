# user-mod.sh
Modify an input list of base usernames. New text can be added to the beginning, middle, or end of each input line. New text can include a fixed string, or generated text including letters a-z or 1-4 digit numbers. 

## Usage
```
./user-mod.sh -i [inputfilename] [mode [modeparameter]]-p [positionparameter] -o [outputfilename]
```

* **-i [filename]** specifies the input file, and is required. Each line of the input file will be read as an input string.
* **[mode] [paramter]** specifies whether string mode will be used to add a fixed string to each input line, or if generator mode will be used to add letters or numbers.
  - **-s [string]** specifies that string mode will be used to add [string] to each line.
    - You can also insert your input lines into the middle of a string by using a '~' in the string parameter (Ex: `-s x~y`, where x is the first part of your substring and y is the second). This eliminates the need to set -p.
  - **-g [format]** specifies that generator mode will be used to generate [format] to add to each line. Formats include:
    - **abc*** - Create letters a-z.
    - **n** - Create numbers 0-9.
    - **nn** - Create numbers 00-99.
    - **nnn** - Create numbers 000-999.
    - **nnnn** - Create numbers 0000-9999.
* **-p [value]** specifies the position where your fixed string or generated text will be added to each line of the input file. Values are:
  - **1** - Add the new text to the beginning of each input line.
  - **2** - Add the new text in the space-delimited middle of each input line. Each input line must include only one space.
  - **3** - Add the new text to the end of each input line.
* **-o [filename]** specifies an output file, which is required.

The examples below may make usage more clear.

## Example 1: Prepend a list of usernames with "admin_"
Input File:
```
jsmith
aadams
bbrown
```
Command:
```
# ./user-mod.sh -i names-flast.txt -s admin_ -p 1 -o testout.txt
```
Results:
```
admin_aadams
admin_bbrown
admin_jsmith
```
## Example 2: Add middle initials to a list of first and last names
Input file:
```
john smith
amy adams
bob brown
```
Command:
```
# ./user-mod.sh -i names-spacedelim.txt -g abc -p 2 -o testout.txt
```
Results:
```
amyaadams
amybadams
amycadams
...
bobybrown
bobzbrown
johnasmith
johnbsmith
...
```
## Example 3: Add 4-digit numbers to the end of possible usernames
Input file: See Example 1

Command:
```
# ./user-mod.sh -i names-flast.txt -g nnnn -p 3 -o testout.txt
```
Results:
```
aadams0000
aadams0001
aadams0003
...
bbrown9998
bbrown9999
jsmith0000
jsmith0001
...
jsmith9999
```
## Example 4: Machines are named [username]-pc, and you want to create a list of SMB URLs to C$ based on a list of usernames
Input file: See Example 1

Command:
```
# ./user-mod.sh -i names-flast.txt -s smb://~-pc/C$/ -o testout.txt
```
Results:
```
smb://aadams-pc/C$/
smb://bbrown-pc/C$/
smb://jsmith-pc/C$/
```
