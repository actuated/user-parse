# user-enum-parse.sh
Extract usernames from the output of common user enumeration tools. Usernames will be converted to lowercase. Output will be limited to unique values and sorted.

## Usage
```
./user-enum-parse.sh -i [inputfilename] [-o [outputfilename]]
```

* **-i [filename]** specifies the input file, and is required. Each line of the input file will be checked against the parsing criteria described below.
* **-o [filename]** specifies an output file, which is not required.

## Parsing Criteria
Each line of the input file will be checked for the following formats. Machine accounts are ignored.

* Colon-Delimited
  - `grep '^[[:graph:]]*\:.*\:.*\:'`
  - This is meant for files like SAM users, passwd, and hashes.
  - Usernames are found before the first ':'.
  - Ex: Administrator:500:[hash]:[hash]:

* Metasploit Summary Output
  - `grep '^\[\*\][[:space:]][[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*[[:space:]][[:graph:]]*[[:space:]]\[.*.]'`
  - This is meant for the comma-delimited summary output given by Metasploit modules like smb_enumusers and smb_lookupsid.
  - Usernames are pulled from the comma-delimited results inside the second '[]'.
  - Ex: [*] 192.168.1.1 DOMAIN [ Administrator, Guest, etc ]

* Rpcclient
  - `grep '^user:.*..rid:.*.$'`
  - This is meant for the line-by-line results of the rpcclient enumdomusers command.
  - Usernames are found between 'user:[' and '] rid:'.
  - Ex: user:[administrator] rid:[0x12a]

* smb_lookupsid
  - `grep '^\[\*\][[:space:]][[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*[[:space:]]USER=[[:graph:]]*[[:space:]]RID=.*$'`
  - This is meant for the line-by-line results of the smb_lookupsid Metasploit module.
  - Usernames are found between 'USER=' and ' RID='.
  - Ex: [*] 192.168.1.1 USER=Administrator RID=500

## Example Input File
```
user:[rpc1] rid:[0x1f6]
user:[rpc2] rid:[0x3ea]
user:[duplicate] rid:[0x3ec]
user:[rpcmachine$] rid:[0x3ff]
[*] 192.168.1.1 USER=s2n1 RID=500
[*] 192.168.1.1 USER=s2n2 RID=500
[*] 192.168.1.1 USER=duplicate RID=501
[*] 192.168.1.1 USER=s2nmachine$ RID=502
[*] 192.168.1.1 GROUP=s2n group RID=512
# [*] 192.168.1.1 GROUP=Domain Users RID=513
[*] 192.168.1.1 SMBLOOKUPSID [ msf1, msf2, duplicate, msfmachine$ ] ( LockoutTries=3 PasswordMin=8 )
[*] 192.168.1.1 SMBENUMUSERS [msf2-1, msf2-2, duplicate, msf2machine$ ]

Hash1:500:NO PASSWORD*********************:NO PASSWORD*********************:::
Hash2:501:::
duplicate:502:NO PASSWORD*********************:1AEFAA29F43B879EEB72CE4E12345678:::
hashmachine$::responderdomain:hash:hash

passwd1:x:0:0:root:/root:/bin/bash
passwd2:x:1:1:daemon:/usr/sbin:/bin/sh
duplicate:x:2:2:bin:/bin:/bin/sh
```

## Example Run
```
# ./user-enum-parse.sh -i test.txt 

====================[ User Enum Parser - by tedr@tracesecurity.com ]=====================

Reading from test.txt for username enumeration results.

Press Enter to continue...

=====================================[ Extraction ]======================================

20 Found (13 Unique Non-Machine Accts) in 27 Lines Read

Colon-Delimited: 6    MSF Summary: 8
RPC Client: 3         SMB_LookupSID: 3

Press Enter to display results...

=======================================[ Output ]========================================

duplicate
hash1
hash2
msf1
msf2
msf2-1
msf2-2
passwd1
passwd2
rpc1
rpc2
s2n1
s2n2

========================================[ fin. ]=========================================
```
