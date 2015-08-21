Function Add-RemarkedText

{

 <#

   .Synopsis

    This function will add a remark # character to beginning of line

   .Description

    This function will add a remark character # to selected text in the ISE.

    These are comment characters, and is great when you want to comment out

    a section of PowerShell code.

   .Example

    Add-RemarkedText

    adds the comment / remark character to beginning of each selected line

   .Notes

    NAME:  Add-RemarkedText

    AUTHOR: ed wilson, msft

    LASTEDIT: 05/16/2013

    KEYWORDS: Windows PowerShell ISE, Scripting Techniques

    HSG: wes-5-18-13

   .Link

     Http://www.ScriptingGuys.com

 #Requires -Version 2.0

 #>

 $text = $psISE.CurrentFile.editor.selectedText

 foreach ($l in $text -split [environment]::newline)

  {

   $newText += "{0}{1}" -f ("#" + $l),[environment]::newline

  }

   $psISE.CurrentFile.Editor.InsertText($newText)

} #End function add-remarkedtext



Function Remove-RemarkedText

{

 <#

   .Synopsis

    This function will remove a remark # character to beginning of line

   .Description

    This function will remove a remark character # to selected text in the ISE.

    These are comment characters, and is great when you want to clean up a

    previously commentted out section of PowerShell code.

   .Example

    Remove-RemarkedText

    Removes the comment / remark character to beginning of each selected line

   .Notes

    NAME:  Add-RemarkedText

    AUTHOR: ed wilson, msft

    LASTEDIT: 05/16/2013

    KEYWORDS: Windows PowerShell ISE, Scripting Techniques

    HSG: wes-5-18-13

   .Link

     Http://www.ScriptingGuys.com

 #Requires -Version 2.0

 #>

 $text = $psISE.CurrentFile.editor.selectedText

 foreach ($l in $text -split [environment]::newline)

  {

   $newText += "{0}{1}" -f ($l -replace '#',''),[environment]::newline

  }

   $psISE.CurrentFile.Editor.InsertText($newText)

} #End function remove-remarkedtext