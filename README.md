# user-parse
Shell scripts for username parsing. Convert information gathering results into possible usernames, extract results from common user enumeration tools, and modify a list of base usernames by prepending, inserting, or generating a string, letters, or numbers.

# Scripts
Each of these shell scripts will have their own `README_[script-name].md` file for examples and more detailed usage information.

`user-enum-parse.sh` is a script that will extract usernames from common user enumeration tool results. This includes the comma-delimited Metasploit summary retrieved by tools like smb_enumusers and smb_lookupsid, as well as rpcclient enumdomusers output, the line-by-line output of smb_lookupsid, and colon-delimited lines like SAM, passwd, and John-format hash captures. Unique, lowercase usernames will be extracted from an input file, which can include a mix of different input formats.

`user-mod.sh` is a script for modifying a list of username bases. New text can be added to the beginning or end of each line of your input file, or if you format your input file with two space-delimited substrings per line, it can be inserted in between them. New text can include a fixed string, letters a-z, or 1-4 digit numbers. Examples might include adding "admin_" to the beginning of a list of usernames, or using first and last names to generate possible usernames that include a middle initial, or end with a 4-digit employee ID.

`user-parse.sh` is a script for converting information gathering results into possible usernames. Each line of your input will be checked to see if it follows the formats "user@domain", "domain\user", "First Last" or "Last, First". Lines with first and last names will be converted to a selected format, including "jsmith", "john.smith", "john_smith", "johns", or "johnsmith".
