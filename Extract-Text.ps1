#############################################################################
# Select-string will return the entire line which matches a regex pattern,
# but this filter will extract just the matching text of the pattern.
# Pipe strings or file objects into the filter, and don't forget that you
# may sometimes need to pipe into out-string first.  If your regex includes
# any parentheses to define submatches, then only the submatches are
# extracted, not the entire regex match, unless you put the whole regex
# inside parentheses.  Multiple submatches are OK, so are nested submatches.
# Blank output lines are suppressed, like from submatches with alternation.
# Author: Jason Fossen
# Version: 1.0
#############################################################################

filter extract-text ($RegularExpression) 
{ 
    select-string -inputobject $_ -pattern $regularexpression -allmatches | 
    select-object -expandproperty matches | 
    foreach { 
        if ($_.groups.count -le 1) { if ($_.value){ $_.value } } 
        else 
        {  
            $submatches = select-object -input $_ -expandproperty groups 
            $submatches[1..($submatches.count - 1)] | foreach { if ($_.value){ $_.value } } 
        } 
    }
}




# Notes:
# Each Match object has a Groups property which is an array of one
# or more Group objects.  The first Group object is the matching
# text of the entire regex, while any additional Group objects
# beyond the first represent the submatches.  
# 
# Examples:
# ipconfig.exe /all | extract-text 'Description'
# ipconfig.exe /all | extract-text 'De(script)ion'
# ipconfig.exe /all | extract-text 'De(sc(ri)pt)ion'
# ipconfig.exe /all | extract-text 'De(sc(ri)(pt))ion'
# ipconfig.exe /all | extract-text 'De(sc((r)i)(pt))ion'
# ipconfig.exe /all | extract-text '(De(sc((r)i)(pt))ion)'


# Just for demos...
$input | extract-text $args[0]


