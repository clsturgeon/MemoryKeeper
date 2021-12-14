GEDCOM2JSON - PowerShell script

This script attempts to convert the content in a 
GEDCOM file to json file. This json file can then
be imported into a Memory Keeper HTML file--using 
the Import button on the Tools tab found on the 
right sidebar.

Usage:

At a command prompt type:

powershell -f GEDCOM2JSON.ps1

Alternatively, in Windows Explorer, right-mouse 
click on the GEDCOM2JSON.ps1 file and select 
Run as Powershell


If it fails with execution policy error... 
trying changing your exeucution policy with this command line:

PowerShell Set-ExecutionPolicy -ExecutionPolicy RemoteSigned


Points to consider:

1. PowerShell script runs under Windows.

2. The script generates a json file from a gedcom file.  
   This json file can be imported into a MK.

3. The PS script attempts to ensure all tiddlers will be 
   unique, which means in some cases the chosen name will
   not be ideal.  In those cases, the GEDCOM ID is appended
   to the name. Once imported into MK you can change any 
   tiddlers title.

4. Caption field for person tiddlers will only contain 
   the name of the individual.

5. The nature of PS seems to be as it gets further into 
   the script the slower it becomes.  The largest GEDCOM 
   I have tested was with more than 12,000 individuals and 
   more than 16,000 events.  This is not ideal for this PS 
   script or for MK.  On an old slow laptop this script took 
   about a day to run.  On my laptop i5 processor, with 16GB 
   of RAM it was took about 3-4 hours. In short, if you want 
   to import a gedcom file with thousands of individuals it 
   will be slow.

6. Not all supported GECOM tags are supported in the PS 
   script.  More can be added if required.

7. A log file (tiddlers.log) is generated to help with 
   debugging.  A common problem with the script has been not 
   properly encoding special characters found in the data of 
   a GEDCOM file, characters that cause json to be invalid.  
   Changes have been made to address this issue.

8. The script logs information to the screen as well.  
   It helps inform the user that is still running/working 
   and provides a few clues where it is in process of the 
   GEDCOM file.  Admittedly, logging to disk and to the 
   screen reduces the performance.