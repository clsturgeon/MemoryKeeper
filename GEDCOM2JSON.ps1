#Browsing file
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$FileBrowser.filter = "Txt (*.ged)| *.ged"
[void]$FileBrowser.ShowDialog()
If(![System.IO.File]::Exists($FileBrowser.FileName)) { exit }
$Individuals = @()
$Sources = @()
$Families = @()
$CurrentObject=""
$Currentlevel=""
$lineno=0
$outputLog=[System.IO.Path]::GetDirectoryName($FileBrowser.FileName) + "\tiddlers.log"
echo "reading... $($FileBrowser.FileName)" > $outputLog
# read file, create objects
foreach($line in Get-Content $FileBrowser.FileName) {
    $parameters = $line.Split(" ")
    $lineno++;
    $level = $parameters[0]
    $data = $parameters[1]
    switch ($level) {
        "0" {

            if ($NewEvent -ne $null -AND $CurrentObject -eq "INDI")  {
                        if ($NewIndividual.PSobject.Properties.name -eq "Events") {
                        } else {
                            $NewIndividual | Add-Member -type NoteProperty -name Events -value @()
                        }
                        $NewIndividual.Events += $NewEvent
                        $NewEvent = $null
                        $CurrentField=""
            }
            if ($NewEvent -ne $null -AND $CurrentObject -eq "FAM")  {
                        if ($NewFamily.PSobject.Properties.name -eq "Events") {
                        } else {
                            $NewFamily | Add-Member -type NoteProperty -name Events -value @()
                        }
                        $NewFamily.Events += $NewEvent
                        $NewEvent = $null
                        $CurrentField=""
            }

            if ($NewNote -ne $null -AND $CurrentObject -eq "INDI")  {
                        if ($NewIndividual.PSobject.Properties.name -eq "Notes") {
                        } else {
                            $NewIndividual | Add-Member -type NoteProperty -name Notes -value @()
                        }
                        $NewIndividual.Notes += $NewNote
                        $NewNote = $null
                        $CurrentField=""
            }
            
            if ($NewNote -ne $null -AND $CurrentObject -eq "FAM")  {
                        if ($NewFamily.PSobject.Properties.name -eq "Notes") {
                        } else {
                            $NewFamily | Add-Member -type NoteProperty -name Notes -value @()
                        }
                        $NewFamily.Notes += $NewNote
                        $NewNote = $null
                        $CurrentField=""
            }
            $ObjType=$data
            if ("$($ObjType)" -eq "HEAD" -OR "$($ObjType)" -eq "TRLR") {
                echo "ignore head and trlr records"
            } else {
               switch ($parameters[2]) {
                    "INDI" {
                           if ($CurrentObject -eq "INDI") {
                                #echo "reading new indi without closing previous"
                                $theDate=Get-Date -Format "dd-MMM-yyyy"
                                $theTime=Get-Date -Format "hh:mm:ss"
                                $NewIndividual | Add-Member -type NoteProperty -name RecordDate -value $theDate;
                                $NewIndividual | Add-Member -type NoteProperty -name RecordTime -value $theTime; 
                                $Individuals += $NewIndividual;
                                $CurrentObject=""
                                $CurrentLevel=""
                                $CurrentField=""
                           }
                           if ($CurrentObject -eq "SOUR") {
                                #echo "reading new indi without closing a SOUR"
                                $theDate=Get-Date -Format "dd-MMM-yyyy"
                                $theTime=Get-Date -Format "hh:mm:ss"
                                $NewIndividual | Add-Member -type NoteProperty -name RecordDate -value $theDate;
                                $NewIndividual | Add-Member -type NoteProperty -name RecordTime -value $theTime; 
                                $Sources += $NewSource;
                                $CurrentObject=""
                                $CurrentLevel=""
                                $CurrentField=""
                           }

                           $CurrentObject=$parameters[2]
                           $ObjectId=$data.SubString(1, $data.LastIndexOf("@")-2)
                           echo "Individual: $($data)"
                           echo "Individual: $($data)" >> $outputLog
                           $NewIndividual = New-Object System.Object
                           $NewIndividual | Add-Member -type NoteProperty -name SystemId -value $data
                           $NewIndividual | Add-Member -type NoteProperty -name NickName -value ""
                           $NewIndividual | Add-Member -type NoteProperty -name Occupations -value ""
                           $NewIndividual | Add-Member -type NoteProperty -name CaptionTitle -value "";
                           
                           $NewIndividual | Add-Member -type NoteProperty -name TiddlerTitle -value ""
                           break
                    }
                    "FAM" {
                         if ($CurrentObject -eq "INDI") {
                            #echo "reading family without closing individual"
                            $theDate=Get-Date -Format "dd-MMM-yyyy"
                            $theTime=Get-Date -Format "hh:mm:ss"
                            $NewIndividual | Add-Member -type NoteProperty -name RecordDate -value $theDate;
                            $NewIndividual | Add-Member -type NoteProperty -name RecordTime -value $theTime; 
                            $Individuals += $NewIndividual;
                            $CurrentObject=""
                            $CurrentLevel=""
                            $CurrentField=""
                         } else {
                            if ($CurrentObject -eq "FAM") {
                                #echo "reading family without closing previous family"
                                $theDate=Get-Date -Format "dd-MMM-yyyy"
                                $theTime=Get-Date -Format "hh:mm:ss"
                                $NewFamily | Add-Member -type NoteProperty -name RecordDate -value $theDate;
                                $NewFamily | Add-Member -type NoteProperty -name RecordTime -value $theTime; 
                                $Families += $NewFamily;
                                $CurrentObject=""
                                $CurrentLevel=""
                                $CurrentField=""
                            }
                         }
                         $CurrentObject=$parameters[2]
                         $ObjectId=$data.SubString(1, $data.LastIndexOf("@")-2)
                         echo "Family: $($data)"
                         echo "Family: $($data)" >> $outputLog
                         $NewFamily = New-Object System.Object
                         $NewFamily | Add-Member -type NoteProperty -name SystemId -value $data
                         break
                    }
                    "SOUR" {
                        if ($CurrentObject -eq "INDI") {
                            #echo "reading family without closing individual"
                            $theDate=Get-Date -Format "dd-MMM-yyyy"
                            $theTime=Get-Date -Format "hh:mm:ss"
                            $NewIndividual | Add-Member -type NoteProperty -name RecordDate -value $theDate;
                            $NewIndividual | Add-Member -type NoteProperty -name RecordTime -value $theTime; 
                            $Individuals += $NewIndividual;
                            $CurrentObject=""
                            $CurrentLevel=""
                            $CurrentField=""
                         } 
                         
                        if ($CurrentObject -eq "FAM") {
                            #echo "reading family without closing previous family"
                            $theDate=Get-Date -Format "dd-MMM-yyyy"
                            $theTime=Get-Date -Format "hh:mm:ss"
                            $NewFamily | Add-Member -type NoteProperty -name RecordDate -value $theDate;
                            $NewFamily | Add-Member -type NoteProperty -name RecordTime -value $theTime; 
                            $Families += $NewFamily;
                            $CurrentObject=""
                            $CurrentLevel=""
                            $CurrentField=""
                        }
                        if ($CurrentObject -eq "SOUR") {
                            #echo "reading source without closing previous source"
                            $theDate=Get-Date -Format "dd-MMM-yyyy"
                            $theTime=Get-Date -Format "hh:mm:ss"
                            $NewSource | Add-Member -type NoteProperty -name RecordDate -value $theDate;
                            $NewSource | Add-Member -type NoteProperty -name RecordTime -value $theTime; 
                            $Sources += $NewSource;
                            $CurrentObject=""
                            $CurrentLevel=""
                            $CurrentField=""
                        }
                        
                        $CurrentObject=$parameters[2]
                        $ObjectId=$data.SubString(1, $data.LastIndexOf("@")-2)
                        echo "Source: $($data)"
                        echo "Source: $($data)" >> $outputLog
                        $NewSource = New-Object System.Object
                        $NewSource | Add-Member -type NoteProperty -name SystemId -value $data
                        break
                    }
                
               }


               }

           
      
            }
        

        "1" {
   
            $Currentlevel=$level
            switch ($CurrentObject) {
                "INDI" {

                    if ($NewEvent -ne $null) {
                        if ($NewIndividual.PSobject.Properties.name -eq "Events") {
                        } else {
                            $NewIndividual | Add-Member -type NoteProperty -name Events -value @()
                        }
                        $NewIndividual.Events += $NewEvent
                        $NewEvent = $null
                        $CurrentField=""
                    }

                    if ($NewNote -ne $null) {
                        if ($NewIndividual.PSobject.Properties.name -eq "Notes") {
                        } else {
                            $NewIndividual | Add-Member -type NoteProperty -name Notes -value @()
                        }
                        $NewIndividual.Notes += $NewNote
                        $NewNote = $null
                        $CurrentField=""
                    }

                    if ($CurrentField -eq $data) {
                   
                    
                        switch ($data) {
                           "NAME"  {
                                 if ($line > 6) {
                                    $name = $line.Substring(7);
                                 } else {
                                    $name = "no given name /nosurname/"
                                 }
                                 echo "NICKNAME: $($name)"
                                 $NewIndividual.NickName=$NewIndividual.NickName + $name + ";"; break; }
                           "OCCU"  { 
                                 if ($line > 6) {
                                    $name = $line.Substring(7);
                                    $NewIndividual.Occupations=$NewIndividual.Occupations + "[[" + $name + "]]" + " "; break; }
                                 }
                           "FAMS"  { break}
                           "FAMC"  { break}
                           "WILL"  { break}
                           "LAND"  {break}
                           "EMPLYMT" {break}
                           "MOVE" {break}
                           "ILLN" {break}
                           "HLTHCHK" {break}
                           "MOVE" {break}
                           "HLTHCHK" {break}
                           "MOVE" {break}
                           "LND_PURC" {break}
                           "LND_SALE" {break}
                           "GRAD"  {break}
                           "SOUR"  {break}
                           "MILI" {break}
                           "EVEN" {break}
                           "PLAC" {break}
                           "NOTE" {break}
                           "EMIG" {break}
                           "IMMI" {break}
                           "DSCR" {break}
                            default { echo "     duplicate unknown token in INDI: $($data)"; break}
                        }
                    } else {
                        $CurrentField=$data
                        switch ($data) {
                           "NAME"  { 
                                    if ($line.Length -gt 6 ) {
                                        $name = $line.Substring(7)
                                    } else {
                                        $name = "no given name /noname/"
                                    }
                                    echo "NAME: $($name)"
                                   
                                     $NewIndividual | Add-Member -type NoteProperty -name Name -value $name
                                     break}
                           "SEX"   {$NewIndividual | Add-Member -type NoteProperty -name Sex -value $parameters[2]
                                    break}
                           "AFN"   {$NewIndividual | Add-Member -type NoteProperty -name Afn -value $parameters[2]
                                    break}
                           
                           "BIRT" {$NewEvent = New-Object System.Object
                                    $NewEvent | Add-Member -type NoteProperty -name EventLabel -value $data
                                    $name="Birth"
                                    $NewEvent | Add-Member -type NoteProperty -name Type -value $name;
                                    break}

                           "DEAT" {$NewEvent = New-Object System.Object
                                    $NewEvent | Add-Member -type NoteProperty -name EventLabel -value $data
                                    $name="Death"
                                    $NewEvent | Add-Member -type NoteProperty -name Type -value $name;
                                    break}

                           "BURI" {$NewEvent = New-Object System.Object
                                    $NewEvent | Add-Member -type NoteProperty -name EventLabel -value $data
                                    $name="Burial"
                                    $NewEvent | Add-Member -type NoteProperty -name Type -value $name;
                                    break}
                         
                           "CENS" {$NewEvent = New-Object System.Object
                                    $NewEvent | Add-Member -type NoteProperty -name EventLabel -value $data
                                    $name="Census"
                                    $NewEvent | Add-Member -type NoteProperty -name Type -value $name;
                                    break}

                           {($_ -eq  "EVEN") -or ($_ -eq "EMPLYMT") -or ($_ -eq "MILI") -or
                                ($_ -eq "WILL") -or ($_ -eq "LAND") -or ($_ -eq "CHR") -or ($_ -eq "BAPM") -or ($_ -eq "ILLN") -or ($_ -eq "HLTHCHK") -or
                                ($_ -eq "MOVE") -or ($_ -eq "LND_PURC") -or ($_ -eq "LND_SALE") -or ($_ -eq "GRAD") -or ($_ -eq "EMIG") -or ($_ -eq "IMMI") -or
                                ($_ -eq "ENRLMNT") -or ($_ -eq "DEAT_NOTE")
                           }
                                { 
                                    $NewEvent = New-Object System.Object
                                    $NewEvent | Add-Member -type NoteProperty -name EventLabel -value $data
                                    break
                                 }  #no parameters, DATE, TYPE, DSCR - which could have CONC, CONT
                          
                           "PLAC"  { 
                                    $name = $line.Substring(7)
                                    $Place = New-Object System.Object
                                    $Place | Add-Member -type NoteProperty -name SystemId -value $name
                                    if ($NewIndividual.PSobject.Properties.name -eq "Places") {
                                    } else {
                                        $NewIndividual | Add-Member -type NoteProperty -name Places -value @()
                                    }
                                    $NewIndividual.Places += $Place
                                    $CurrentField=""
                            break}
                           "NOTE"  { 
                                    if ($line.Length -gt 6 ) {
                                        $name = $line.Substring(7)
                                    } else {
                                        $thenotedate = (Get-Date).ToString('yyyy-MM-dd hh:mm:ss tt')
                                        $name = "$($thenotedate) - Note"
                                    }
                                    $NewNote = New-Object System.Object
                                    $NewNote | Add-Member -type NoteProperty -name Note -value $name

                                    
                                     #$name = $line.Substring(7)
                                     #if ($NewIndividual.PSobject.Properties.name -eq "Note") {
                                     #       $NewIndividual.Note=$NewIndividual.Note + "<br /><br />" + $name
                                     #} else {
                                     #       $NewIndividual | Add-Member -type NoteProperty -name Note -value $name
                                     #}
                                     break}
                           "SOUR"  {
                                    $IndiSource = New-Object System.Object
                                    $IndiSource | Add-Member -type NoteProperty -name SystemId -value $parameters[2]
                                    if ($NewIndividual.PSobject.Properties.name -eq "Sources") {
                                    } else {
                                        $NewIndividual | Add-Member -type NoteProperty -name Sources -value @()
                                    }
                                    $NewIndividual.Sources += $IndiSource
                                    $CurrentField="" 
                                    break}
                     
                           "OCCU"  { 
                                    $name = $line.Substring(7)
                                    $Occpation = New-Object System.Object
                                    $Occpation | Add-Member -type NoteProperty -name SystemId -value $name
                                    if ($NewIndividual.PSobject.Properties.name -eq "Occpations") {
                                    } else {
                                        $NewIndividual | Add-Member -type NoteProperty -name Occpations -value @()
                                    }
                                    $NewIndividual.Occpations += $Occpation
                                    $CurrentField=""
                                    break}
                           
                           "FAMC"  { 
                                if ($NewIndividual.PSobject.Properties.name -eq "FamilyIdAsChild") {
                                    $NewIndividual.FamilyIdAsChild=$NewIndividual.FamilyIdAsChild + ";" + $parameters[2]
                                } else {
                                    $NewIndividual | Add-Member -type NoteProperty -name FamilyIdAsChild $parameters[2]
                                }
                                $CurrentField=""
                                break}  #as CHILD
                           "FAMS"  {
                                if ($NewIndividual.PSobject.Properties.name -eq "FamilyIdAsSpouse") {
                                    $NewIndividual.FamilyIdAsSpouse=$NewIndividual.FamilyIdAsSpouse + ";" + $parameters[2]
                                } else {
                                     $NewIndividual | Add-Member -type NoteProperty -name FamilyIdAsSpouse $parameters[2]
                                }
                                $CurrentField=""
                                break}  #as SPOUSE
                           "CHAN"  { break}
                           "RIN"   { break }
                           "_UID"   { break }
                           "_UPD"   { break }
                           "DSCR"  {
                                     if ($line.Length -gt 6 ) {
                                        $name = $line.Substring(7)
                                     } else {
                                        $thedescdate = (Get-Date).ToString('yyyy-MM-dd hh:mm:ss tt')
                                        $name = "$($thedescdate) - Description"
                                     }

                                     if ($NewIndividual.PSobject.Properties.name -eq "Description") {
                                            $NewIndividual.Note=$NewIndividual.Description + "<br /><br />" + $name
                                     } else {
                                            $NewIndividual | Add-Member -type NoteProperty -name Description -value $name
                                     }
                                     break}  
                           
                           "NMR" { $NewIndividual | Add-Member -type NoteProperty -name NumberOfMarriages-value $parameters[2];           #number of marriages
                                   break}
                           
                           "NCHI"  {$NewIndividual | Add-Member -type NoteProperty -name NumberOfChildren-value $parameters[2]; 
                                    break}
                           default {"Unknown token in INDI: $($data)"; break}
                        }
                    }
                    break
                }
            
                "FAM" {
                    if ($NewEvent -ne $null) {
                        if ($NewFamily.PSobject.Properties.name -eq "Events") {
                        } else {
                            $NewFamily | Add-Member -type NoteProperty -name Events -value @()
                        }
                        $NewFamily.Events += $NewEvent
                        $NewEvent = $null
                        $CurrentField=""
                    }

                    if ($NewNote -ne $null) {
                        if ($NewFamily.PSobject.Properties.name -eq "Notes") {
                        } else {
                            $NewFamily | Add-Member -type NoteProperty -name Notes -value @()
                        }
                        $NewFamily.Notes += $NewNote
                        $NewNote = $null
                        $CurrentField=""
                    }
                    if ($CurrentField -eq $data) {
                        switch ($data) {
                            "HUSB" {break}
                            "WIFE" {break}
                            "CHIL" {break}
                            "MARR" {break}
                            "EVEN" {break}
                            "DIV"  {break}
                            "ANNVRY" {break}
                            "MARR_INTNT" {break}
                            "LND_PURC" {break}
                            default {"     duplicate unknown token in FAM: $($data)"; break}
                        }
                    } else {
                        $CurrentField=$data
                        switch ($data) {
                            "HUSB" {
                                    
                                    $NewFamily | Add-Member -type NoteProperty -name HusbandId -value $parameters[2]
                                    
                                    break}
                            "WIFE" {
                                    $NewFamily | Add-Member -type NoteProperty -name WifeId -value $parameters[2]
                                    
                                    break}
                            "CHIL" {
                                    $Child = New-Object System.Object
                                    $Child | Add-Member -type NoteProperty -name SystemId -value $parameters[2]
                                    if ($NewFamily.PSobject.Properties.name -eq "Children") {
                                    } else {
                                        $NewFamily | Add-Member -type NoteProperty -name Children -value @()
                                    }
                                    $NewFamily.Children += $Child
                                    $CurrentField=""
                                    break}
                            "MARR" {$NewEvent = New-Object System.Object
                                    $NewEvent | Add-Member -type NoteProperty -name EventLabel -value $data
                                    $name="Marriage"
                                    $NewEvent | Add-Member -type NoteProperty -name Type -value $name;
                                    break}
                            "DIV" {
                                    $NewEvent = New-Object System.Object
                                    $NewEvent | Add-Member -type NoteProperty -name EventLabel -value $data
                                    $name="Divorce"
                                    $NewEvent | Add-Member -type NoteProperty -name Type -value $name;
                                    break}
                            { ($_ -eq "EVEN") -or ($_ -eq  "ANNVRY") -or ($_ -eq "MARR_INTNT") -or ($_ -eq "LND_PURC") 
                           }
                                { 
                                    $NewEvent = New-Object System.Object
                                    $NewEvent | Add-Member -type NoteProperty -name EventLabel -value $data
                                    break
                                 } 
                            "RIN" {break}
                            "_UID" {break}
                            default {"Unknown token in FAM: $($data)"; break}
                        }
                    }
                    break
                }
                "SOUR" {
                      if ($NewNote -ne $null) {
                        if ($NewSource.PSobject.Properties.name -eq "Notes") {
                        } else {
                            $NewSource | Add-Member -type NoteProperty -name Notes -value @()
                        }
                        $NewSource.Notes += $NewNote
                        $NewNote = $null
                        $CurrentField=""
                     }
                     if ($CurrentField -eq $data) {
                        switch ($data) {
                            "TEXT" {
                                        $name = $line.Substring(7)
                                        $NewSource.SOURCE_TEXT=$NewSource.SOURCE_TEXT + "<br />" + $name
                                   }
                            "DATE" {break}
                            "EVEN" {break}
                            "FIDE" {break}
                            "NAME" {break}
                            "PAGE" {break}
                            "QUAY" {break}
                            "RECO" {break}
                            "AUTH" {break}
                            "PUBL" {break}
                            "NOTE" {break}
                            default {"     duplicate unknown token in SOUR: $($data)"; break}
                        }
                    } else {
                        $CurrentField=$data
                        switch ($data) {
                            "TEXT" {
                                        $name = $line.Substring(7);
                                        if ($NewSource.PSobject.Properties.name -eq "SOURCE_TEXT") {
                                            $NewSource.SOURCE_TEXT=$NewSource.SOURCE_TEXT + "<br /><br />" + $name
                                        } else {
                                            $NewSource | Add-Member -type NoteProperty -name SOURCE_TEXT -value $name; 
                                        }
                                    }
                            "CLAS" {$NewSource | Add-Member -type NoteProperty -name CLASSIFICATION_CODE -value $parameters[2]; }
                            "DATE" {$NewSource | Add-Member -type NoteProperty -name Date -value $parameters[2]; }
                            "EVEN" {$NewSource | Add-Member -type NoteProperty -name EVENT_CLASSIFICATION_CODE -value $parameters[2]; } 
                            "FIDE" {$NewSource | Add-Member -type NoteProperty -name FIDELITY_CODE -value $parameters[2];}
                            "NAME" {break}
                            "PAGE" {
                                        $name = $line.Substring(7); 
                                        $NewSource | Add-Member -type NoteProperty -name PAGE_DESCRIPTION -value $name;
                                    }   
                            "QUAY" {$NewSource | Add-Member -type NoteProperty -name QUALITY_OF_DATA -value $parameters[2];}
                            "RECO" {break}
                            "AUTH" {
                                        $name = $line.Substring(7); 
                                        $NewSource | Add-Member -type NoteProperty -name AUTHOR -value $name
                                        break}
                            "PUBL" {break}
                            "NOTE" {
                                        $name = $line.Substring(7)
                                        $NewNote = New-Object System.Object
                                        $NewNote | Add-Member -type NoteProperty -name Note -value $name
                                        break
                                    }
                            default {"Unknown token in SOUR: $($data)"; break}
                        }
                    }
                    break
                }
            
            }
        }
        "2" {
                switch ($CurrentObject) {
                    "INDI" {
                        switch ($CurrentField) {
                        
                           {($_ -eq "BIRT") -or ($_ -eq "DEAT") -or ($_ -eq  "EVEN") -or ($_ -eq "BURI") -or ($_ -eq "EMPLYMT") -or ($_ -eq "MILI") -or
                                ($_ -eq "WILL") -or ($_ -eq "LAND") -or ($_ -eq "CHR") -or ($_ -eq "BAPM") -or ($_ -eq "ILLN") -or ($_ -eq "HLTHCHK") -or
                                ($_ -eq "MOVE") -or ($_ -eq "LND_PURC") -or ($_ -eq "LND_SALE") -or ($_ -eq "GRAD") -or ($_ -eq "EMIG") -or ($_ -eq "IMMI") -or
                                ($_ -eq "ENRLMNT") -or ($_ -eq "CENS") -or ($_ -eq "DEAT_NOTE")
                           } {
                                switch ($data) {
                                    "DATE" {
                                        $name=$line.Substring(7)
                                        $NewEvent | Add-Member -type NoteProperty -name Date -value $name; break;}
                                    "PLAC" {
                                        $name = $line.Substring(7)
                                        $NewEvent | Add-Member -type NoteProperty -name Place -value $name; break;}
                                    #"DSCR" {$NewEvent | Add-Member -type NoteProperty -name Descriptions -value $parameters[2]; break;}
                                    "TYPE" {
                                        if (!$NewEvent.PSobject.Properties.name -match "Type") {
                                            $name = $line.Substring(7)
                                            $NewEvent | Add-Member -type NoteProperty -name Type -value $name; break;
                                        }
                                        }
                                    "SOUR" {
                                        $EventSource = New-Object System.Object
                                        $EventSource | Add-Member -type NoteProperty -name SystemId -value $parameters[2]
                                        if ($NewEvent.PSobject.Properties.name -eq "Sources") {
                                        } else {
                                            $NewEvent | Add-Member -type NoteProperty -name Sources -value @()
                                        }
                                        $NewEvent.Sources += $EventSource
                                        #$CurrentField="" 
                                        break}

                                    
                                }
                           }



                            "NOTE" {
                                switch ($data) {
                                    "CONC" {
                                        if ($line.Length -gt 6) {
                                            $name = $line.Substring(7)
                                            #$NewIndividual.Note=$NewIndividual.Note + " " + $name 
                                            $NewNote.Note=$NewNote.Note + " " + $name
                                        }
                                        break }
                                    "CONT" { 
                                        if ($line.Length -gt 6) {
                                            $name = $line.Substring(7)
                                            #$NewIndividual.Note=$NewIndividual.Note + "<br />" + $name
                                            $NewNote.Note=$NewNote.Note + " " + $name
                                         }
                                        break }
                                }
                            }
                            "PUBL" {
                                switch ($data) {
                                    "DATE" {$NewIndividual | Add-Member -type NoteProperty -name PUBLICATION_DATE -value $parameters[2]; break;}
                                    "TYPE" {$NewIndividual | Add-Member -type NoteProperty -name PUBLICATION_TYPE -value $parameters[2]; break;}

                                }
                            }
                            "CHAN" {
                                switch ($data) {
                                    "DATE" {$NewIndividual | Add-Member -type NoteProperty -name RecordDate -value $parameters[2]; break;}
                               
                                }
                            }
                        }
                    }
                    "FAM" {
                        switch ($CurrentField) {
                        
                          {($_ -eq "MARR") -or ($_ -eq "EVEN") -or ($_ -eq  "ANNVRY") -or ($_ -eq "DIV") -or ($_ -eq "MARR_INTNT") -or ($_ -eq "LND_PURC") 
                           } {
                                switch ($data) {
                                    "DATE" {
                                        $name=$line.Substring(7)
                                        $NewEvent | Add-Member -type NoteProperty -name Date -value $name; break;}
                                    "PLAC" {
                                        $name = $line.Substring(7)
                                        $NewEvent | Add-Member -type NoteProperty -name Place -value $name; break;}
                                    #"DSCR" {$NewEvent | Add-Member -type NoteProperty -name Descriptions -value $parameters[2]; break;}
                                    "TYPE" {
                                        if (!$NewEvent.PSobject.Properties.name -match "Type") {
                                            $name = $line.Substring(7)
                                            $NewEvent | Add-Member -type NoteProperty -name Type -value $name; break;
                                        }
                                        }
                                }
                            }
                          }
                          break}
                          
                            "NOTE" {
                                switch ($data) {
                                    "CONC" {    
                                        $name = $line.Substring(7)
                                        
                                        $NewNote.Note=$NewNote.Note + " " + $name
                                        break }
                                    "CONT" { 
                                        $name = $line.Substring(7)
                                        
                                        $NewNote.Note=$NewNote.Note + " " + $name
                                        break }
                                }
                            }
                    "SOUR" {
                        switch ($CurrentField) {
                            "TEXT" {
                                switch ($data) {
                                    "CONC" {    
                                        $name = $line.Substring(7)
                                        $NewSource.SOURCE_TEXT=$NewSource.SOURCE_TEXT + " " + $name 
                                        break }
                                    "CONT" { $name = $line.Substring(7)
                                        $NewSource.SOURCE_TEXT=$NewSource.SOURCE_TEXT + "<br />" + $name
                                         break }
                                }
                            }
                             "NOTE" {
                                switch ($data) {
                                    "CONC" {    
                                        $name = $line.Substring(7)
                                        #$NewIndividual.Note=$NewIndividual.Note + " " + $name 
                                        $NewNote.Note=$NewNote.Note + " " + $name
                                        break }
                                    "CONT" { 
                                        $name = $line.Substring(7)
                                        #$NewIndividual.Note=$NewIndividual.Note + "<br />" + $name
                                        $NewNote.Note=$NewNote.Note + " " + $name
                                        break }
                                }
                            }
                        }
                    }

                }

            } 
        "3" {
                
                    if ($CurrentObject -eq "INDI") {
                         switch ($CurrentField) {
                            "CHAN" {
                                switch ($data) {
                                    "TIME" {$NewIndividual | Add-Member -type NoteProperty -name RecordTime -value $parameters[2]
                                    $Individuals += $NewIndividual
                                    $CurrentObject=""
                                    $CurrentLevel=""
                                    #echo "Closing new individual object"
                                    break;}
                                }
                            }
                        }
                    }
                }
         
       
    }
}
echo ""

echo "Determining the tiddler titles for each individual..."
echo "Determining the tiddler titles for each individual..." >> $outputLog

#foreach ($indi in $individuals) {
$d=0
for( $i = 0 ; $i -lt $individuals.Count ; $i++ ) {
    if ($Individuals[$i].Name.Length -gt 0) {
        $name = $individuals[$i].Name.Replace("`"", "\`"")
    } else {
        $name = "";
    }
    $names=$name.Split("/").ToLower();
    #$surname=$names[1];
    $surname=(Get-Culture).TextInfo.ToTitleCase($names[1]).Replace(" *", "").Replace("*","").Replace("  ", " ");
    echo "case $($names[1]); $($surname)"
    $givennames = (Get-Culture).TextInfo.ToTitleCase($names[0].TrimEnd(" ")).Replace(" *", "").Replace("*","");
    $pids = $individuals[$i].SystemId.Split("@")
 
    $tiddlerTitle = "$($surname), $($givennames)"
    $captionTitle = "$($givennames) $($surname)"
    foreach ($dupindi in $individuals) {
        $dpids = $dupindi.SystemId.Split("@")
        if ($dpids[1] -ne $pids[1] -AND $individuals[$i].Name -eq $dupindi.Name) {
            #duplicate name, must add ID... to title of tiddler
            $tiddlerTitle = "$($surname), $($givennames) - $($pids[1])"
            $captionTitle = "$($givennames) $($surname)"
            echo "found two individuals with same name $($dupindi.Name); IDs are to be used."
            echo "found two individuals with same name $($dupindi.Name); IDs are to be used." >> $outputLog
            $d++
            break;
        }
    }
    $individuals[$i].TiddlerTitle=$tiddlerTitle
    $individuals[$i].CaptionTitle=$captionTitle

}
$d=$d/2
$u=$individuals.Count - $d
echo "Total number of individuals: $($individuals.Count)"
echo "Total number of individuals: $($individuals.Count)" >>  $outputLog
echo "Total number of individuals with unique names: $($u)"
echo "Total number of individuals with unique names: $($u)" >> $outputLog
echo "Total number of individuals with non-unique names (SystemId was applied to tiddler title): $($d)"
echo "Total number of individuals with non-unique names (SystemId was applied to tiddler title): $($d)" >> $outputLog

#output json - $a=$Families | Select-Object | where-object { $_.SystemId -eq "@F45@"}
$output=[System.IO.Path]::GetDirectoryName($FileBrowser.FileName) + "\tiddlers.json"
echo "[{" > $output
$Total = $individuals.count
$Counter = 0
foreach ($indi in $individuals)
{
    if ($Counter -ne 0) {
        Add-Content -path $output "{"
    }
    #Add-Content -path $output "    `"text`": `"{{`|`|person template}}`","

    #Add-Content -path $output "    `"title`": `"$($surname), $($givennames)- $($pids[1])`","
    Add-Content -path $output "    `"title`": `"$($indi.TiddlerTitle)`","
    Add-Content -path $output "    `"caption`": `"$($indi.CaptionTitle)`","`
    #echo "$($surname), $($givennames) ($($pids[1]))"
    echo $indi.TiddlerTitle
    echo "    caption: $($indi.CaptionTitle)"
    echo $indi.TiddlerTitle >> $outputLog
    Add-Content -path $output "    `"systemId`": `"$($pids[1])`","
    #parse date
    $theDate=Get-Date -Format "yyyyMMddhhmmss000"
    Add-Content -path $output "    `"modified`": `"$($theDate)`","
    if ($indi.Sex -eq "F") {
        Add-Content -path $output "    `"tags`": `"person female`","
        Add-Content -path $output "    `"icon`": `"female`","
    } else {
        if ($indi.Sex -eq "M") {
            Add-Content -path $output "    `"tags`": `"person male`","
            Add-Content -path $output "    `"icon`": `"male`","
        } else {
            Add-Content -path $output "    `"tags`": `"person`","
        }
    }
    if ($indi.Occupations.Length -gt 0) {
        echo "    occupations: $($indi.Occupations)"
        echo "    occupations: $($indi.Occupations)" >> $outputLog
        Add-Content -path $output "    `"occupations`": `"[[$($indi.Occupations)]]`","
    }
    #get parents names
    if ($indi.FamilyIdAsChild -ne $null)
    {
        $family=$Families | Select-Object | where-object { $_.SystemId -eq $indi.FamilyIdAsChild}
        if ($family.HusbandId -ne $null) {
            #get father name
            $father=$Individuals | Select-Object | where-object { $_.SystemId -eq $family.HusbandId}
            echo "    father: $($father.TiddlerTitle)"
            echo "    father: $($father.TiddlerTitle)" >> $outputLog
            Add-Content -path $output "    `"father`": `"[[$($father.TiddlerTitle)]]`","

        }
        if ($family.WifeId -ne $null) {
            #get mother name
            $mother=$Individuals | Select-Object | where-object { $_.SystemId -eq $family.WifeId}
            echo "    mother: $($mother.TiddlerTitle)"
            echo "    mother: $($mother.TiddlerTitle)" >> $outputLog
            Add-Content -path $output "    `"mother`": `"[[$($mother.TiddlerTitle)]]`","
        }
    }
    if ($indi.FamilyIdAsSpouse -ne $null) {
        $family=$Families | Select-Object | where-object { $_.SystemId -eq $indi.FamilyIdAsSpouse}
        if ($family.WifeId -eq $indi.SystemId) {
            if ($family.HusbandId -ne $null) {
                $husband=$Individuals | Select-Object | where-object { $_.SystemId -eq $family.HusbandId}
                echo "    husband: $($husband.TiddlerTitle)"
                echo "    husband: $($husband.TiddlerTitle)" >> $outputLog
                Add-Content -path $output "    `"spouse`": `"[[$($husband.TiddlerTitle)]`","
            }
        }
        if ($family.HusbandId -eq $indi.SystemId) {
            if ($family.WifeId -ne $null) {
                $wife=$Individuals | Select-Object | where-object { $_.SystemId -eq $family.WifeId}
                #$name = $wife.Name.Replace("`"", "\`"")
                #$names=$name.Split("/")
                #$surname=$names[1]
                #$givennames = $names[0]
                #$pids = $family.WifeId.Split("@")
                #echo "    wife: $($surname), $($givennames)($($pids[1]))"
                #Add-Content -path $output "    `"spouse`": `"$($surname), $($givennames)- $($pids[1])`","
                echo "    wife: $($wife.TiddlerTitle)"
                echo "    wife: $($wife.TiddlerTitle)" >> $outputLog
                Add-Content -path $output "    `"spouse`": `"[[$($wife.TiddlerTitle)]]`","
            }
        }
    }

    Add-Content -path $output "    `"created`": `"$($theDate)`""
    $Counter += 1
    #if($Counter -ne $Total) {
        Add-Content -path $output "},"
    #} else {
        #Add-Content -path $output "}"
    #}

    if ($indi.Events -ne $null) {
        #$names=$indi.name.Split("/")
        #$surname=$names[1]
        #$givennames = $names[0]
        #echo "$($givennames)$($surname)"
        #$pids = $indi.SystemId.Split("@")
        foreach ($event in $indi.Events) {
            Add-Content -path $output "{"
            #Add-Content -path $output "    `"text`": `"{{`|`|event template}}`","
            if ($event.Type.Length -gt 0) {
                $eventtype=$event.Type.Replace(" ", "_")
            } else {
                $eventtype=""
            }
            $Label=(Get-Culture).TextInfo.ToTitleCase($event.Type)
             try {
                $tempDate = $($event.Date).Replace(" ","-")
                $workDate=[datetime]::ParseExact("$($tempDate)", "dd-MMM-yyyy", $null).ToString("yyyy-MM-dd")
            } catch {
                if ($event.Date.Length -gt 0) {
                    $workDate=$event.Date.Replace("  ", " ").Replace("( ", "(").Replace(" )", ")").Replace("*", "");
                } else {
                    $workDate="";
                }
            }
            #Add-Content -path $output "    `"title`": `"$($workDate) - $($Label) - $($givennames)$($surname)`","
            if ($workDate.Length -gt 0 -And $Label.Length -gt 0) {
                Add-Content -path $output "    `"title`": `"$($workDate) - $($Label) - $($indi.TiddlerTitle)`","
                echo "    $($workDate) - $($Label)"
                echo "    $($workDate) - $($Label)" >> $outputLog
                Add-Content -path $output "    `"date`": `"$($workDate)`","
            } else {
                if ($workDate.Length -gt 0) {
                    Add-Content -path $output "    `"title`": `"$($workDate) - $($indi.TiddlerTitle)`","
                    echo "    $($workDate)"
                    echo "    $($workDate)" >> $outputLog
                    Add-Content -path $output "    `"date`": `"$($workDate)`","
                } else {
                    if ($Label.Length -gt 0) {
                        Add-Content -path $output "    `"title`": `"$($Label) - $($indi.TiddlerTitle)`","
                        echo "    $($Label)"
                        echo "    $($Label)" >> $outputLog
                    }
                    else {
                        Add-Content -path $output "    `"title`": `"$($indi.TiddlerTitle)`","
                    }
                }
            }
            #Add-Content -path $output "    `"people`": `"[[$($surname), $($givennames)- $($pids[1])]]`","
            Add-Content -path $output "    `"people`": `"[[$($indi.TiddlerTitle)]]`","
            if ($event.Place -ne $null) {
                Add-Content -path $output "    `"place`": `"[[$($event.Place)]]`","
            }
            $theDate=Get-Date -Format "yyyyMMddhhmmss000"
            Add-Content -path $output "    `"modified`": `"$($theDate)`","
            Add-Content -path $output "    `"tags`": `"event $($eventtype)`","
            Add-Content -path $output "    `"icon`": `"$($event.Type)`","
            Add-Content -path $output "    `"created`": `"$($theDate)`""
            Add-Content -path $output "},"
        }
    }

    if ($indi.Notes -ne $null) {
        $names=$indi.name.Split("/").ToLower()
        #$surname=$names[1]
        $surname=(Get-Culture).TextInfo.ToTitleCase($name[1])
        $givennames = (Get-Culture).TextInfo.ToTitleCase($name[0])
        #echo "$($givennames)$($surname)"
        #$pids = $indi.SystemId.Split("@")
        $notecount=0
        foreach ($note in $indi.Notes) {
            Add-Content -path $output "{"
            $name = $note.Note.Replace("`"", "\`"")
            Add-Content -path $output "    `"text`": `"$($name)<br />`","
            $notecount++;
            $length=20
            if($note.Note.Length -lt $length) {
                $length = $note.Note.Length;
            }
                
            $subnote=$note.Note.Substring(0, $length)
            echo "    Note: $($subnote)..."
            echo "    Note: $($subnote)..." >> $outputLog
            Add-Content -path $output "    `"title`": `"Note $($notecount) - $($indi.TiddlerTitle)`","
            #Add-Content -path $output "    `"people`": `"[[$($surname), $($givennames)- $($pids[1])]]`","
            Add-Content -path $output "    `"people`": `"[[$($indi.TiddlerTitle)]]`","
            $theDate=Get-Date -Format "yyyyMMddhhmmss000"
            Add-Content -path $output "    `"modified`": `"$($theDate)`","
            Add-Content -path $output "    `"tags`": `"note`","
            Add-Content -path $output "    `"icon`": `"note`","
            Add-Content -path $output "    `"created`": `"$($theDate)`""
            Add-Content -path $output "},"
        }
    }



    
}

echo "Generate Family Notes and Events (marriage, divorce, etc)"
echo "Generate Family Notes and Events (marriage, divorce, etc)" >> $outputLog

foreach ($family in $Families) {
    if ($family.Events -ne $null) {
        echo "family events for $($family.SystemId)"
        echo "family events for $($family.SystemId)" >> $outputLog
        foreach ($event in $family.Events) {
            Add-Content -path $output "{"
            #Add-Content -path $output "    `"text`": `"{{`|`|event template}}`","
            $eventtype=$event.Type.Replace(" ", "_")
            $Label=(Get-Culture).TextInfo.ToTitleCase($event.Type)
             try {
                $workDate=[datetime]::ParseExact("$($event.Date)", "dd-MMM-yyyy", $null).ToString("yyyy-MM-dd")
            } catch {
                $workDate=$event.Date
            }
            $people=""
            $title=""
            if ($family.HusbandId -ne $null) {
                $husband=$Individuals | Select-Object | where-object { $_.SystemId -eq $family.HusbandId}
                $people=$people + "[[$($husband.TiddlerTitle)]] "
                $title=$title + "$($husband.TiddlerTitle) - "
            }
            if ($family.WifeId -ne $null) {
                $wife=$Individuals | Select-Object | where-object { $_.SystemId -eq $family.WifeId}
                $people=$people + "[[$($wife.TiddlerTitle)]] "
                $title=$title + "$($wife.TiddlerTitle)"
            }
            #Add-Content -path $output "    `"title`": `"$($workDate) - $($Label) - $($givennames)$($surname)`","
            Add-Content -path $output "    `"title`": `"$($workDate) - $($Label) - $($title)`","
            echo "    $($event.Date) - $($Label) - $($title)"
            echo "    $($event.Date) - $($Label) - $($title)" >> $outputLog
            Add-Content -path $output "    `"date`": `"$($workDate)`","
            #Add-Content -path $output "    `"people`": `"[[$($surname), $($givennames)- $($pids[1])]]`","
            #GET NAMES FROM FAMILY--i.e husband and wife.
            

            Add-Content -path $output "    `"people`": `"$($people)`","
            if ($event.Place -ne $null) {
                Add-Content -path $output "    `"place`": `"[[$($event.Place)]]`","
            }
            $theDate=Get-Date -Format "yyyyMMddhhmmss000"
            Add-Content -path $output "    `"modified`": `"$($theDate)`","
            Add-Content -path $output "    `"tags`": `"event $($eventtype)`","
            Add-Content -path $output "    `"icon`": `"$($event.Type)`","
            Add-Content -path $output "    `"created`": `"$($theDate)`""
            Add-Content -path $output "},"
        }
    }

    if ($family.Notes -ne $null) {
        $notecount=0
        foreach ($note in $family.Notes) {
            Add-Content -path $output "{"
            $name = $note.Note.Replace("`"", "\`"")
            #Add-Content -path $output "    `"text`": `"$($name)<br />{{||footnote template}}`","
            $notecount++;
            $length=20
            if($note.Note.Length -lt $length) {
                $length = $note.Note.Length;
            }
            $title=""
            $people=""
            if ($family.HusbandId -ne $null) {
                $husband=$Individuals | Select-Object | where-object { $_.SystemId -eq $family.HusbandId}
                $title=$title + "$($husband.TiddlerTitle) - "
                $people=$people + "[[$($husband.TiddlerTitle)]]; "
            }
            if ($family.WifeId -ne $null) {
                $wife=$Individuals | Select-Object | where-object { $_.SystemId -eq $family.WifeId}
                $title=$title + "$($wife.TiddlerTitle)"
                $people=$people + "[[$($wife.TiddlerTitle)]]; "
            }
            $subnote=$note.Note.Substring(0, $length)
            echo "    Note: $($subnote)..."
            echo "    Note: $($subnote)..." >> $outputLog
            Add-Content -path $output "    `"title`": `"Note $($notecount) - ($title)`","
            
            #get husband and wife names here...



            Add-Content -path $output "    `"people`": `"[[$($people)]]`","
            $theDate=Get-Date -Format "yyyyMMddhhmmss000"
            Add-Content -path $output "    `"modified`": `"$($theDate)`","
            Add-Content -path $output "    `"tags`": `"note`","
            Add-Content -path $output "    `"icon`": `"note`","
            Add-Content -path $output "    `"created`": `"$($theDate)`""
            Add-Content -path $output "},"
        }
    }

}


$Counter=0
echo "Generate source records..."
echo "Generate source records..." >> $outputLog

if ($sources.Count -eq 0) {
    echo "no source records found."
    echo "no source records found." >> $outputLog
}

foreach ($source in $Sources) {

    Add-Content -path $output "{"
    $text=""
    if ($source.SOURCE_TEXT -ne $null) {
        if ($source.SOURCE_TEXT.Length -gt 0) {
            $text = "<br /><br />$($source.SOURCE_TEXT)"
        }
    }
    #Add-Content -path $output "    `"text`": `"{{`|`|source template}}$($text)`","
    
    $pids = $source.SystemId.Split("@")
    Add-Content -path $output "    `"title`": `"$($surname), $($givennames)- $($pids[1])`","

    echo "$($surname), $($givennames) ($($pids[1]))"
    echo "$($surname), $($givennames) ($($pids[1]))" >> $outputLog

    Add-Content -path $output "    `"systemId`": `"$($pids[1])`","

    if ($source.CLASSIFICATION_CODE -ne $null) {
        Add-Content -path $output "    `"classification`": `"$($source.CLASSIFICATION_CODE)`","
    }
    if ($source.Date -ne $null) {
        Add-Content -path $output "    `"date`": `"$($source.Date)`","
    }

    $persons=""
    $indicollection=$Individuals | Select-Object | Where-Object {$_.Sources -ne $null}
    foreach ($indi in $indicollection) {
        foreach ($indisource in $indi.Sources) {
            if ($indisource.SystemId -eq $source.SystemId) {
                $persons = $persons + "[[$($indi.TiddlerTitle)]]; "
                break;
            }
        }
    }

    $famcollection=$Families | Select-Object | Where-Object {$_.Sources -ne $null}
    foreach ($family in $indicollection) {
        foreach ($famsource in $family.Sources) {
            if ($famsource.SystemId -eq $source.SystemId) {

                #get husband and wife name of family record
                if ($family.HusbandId -ne $null) {
                    $husband=$Individuals | Select-Object | where-object { $_.SystemId -eq $family.HusbandId}
                    
                    $persons=$persons + "[[$($husband.TiddlerTitle)]]; "
                }
                if ($family.WifeId -ne $null) {
                    $wife=$Individuals | Select-Object | where-object { $_.SystemId -eq $family.WifeId}
                    
                    $persons=$persons + "[[$($wife.TiddlerTitle)]]; "
                }
                
                break;
            }
        }
    }

    if ($persons.Length -gt 0) {
        Add-Content -path $output "    `"persons`": `"[[$($persons)]]`","
    }


    #parse date
    $theDate=Get-Date -Format "yyyyMMddhhmmss000"
    Add-Content -path $output "    `"modified`": `"$($theDate)`","
    Add-Content -path $output "    `"tags`": `"source`","
    Add-Content -path $output "    `"icon`": `"source`","
    Add-Content -path $output "    `"created`": `"$($theDate)`""
    Add-Content -path $output "},"
}

Add-Content -path $output "{"
Add-Content -path $output "    `"text`": `"GEDCOM Loaded`","
Add-Content -path $output "    `"title`": `"GEDCOM loaded by...`","
$theDate=Get-Date -Format "yyyyMMddhhmmss000"
Add-Content -path $output "    `"modified`": `"$($theDate)`","
Add-Content -path $output "    `"created`": `"$($theDate)`""
echo "}]" >> $output
