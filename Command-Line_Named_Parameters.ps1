##############################################################################
#  Script: Command-Line_Named_Parameters.ps1
#    Date: 14.May.2007
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Demo how command line parameters are processed.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


# If you wish to pass in named parameters instead of using $Args, the
# param keyword must be the first executable line in the script, i.e.,
# the first statement after any blank or comment lines.

# The types of the parameters can be constrained with casts, e.g.,
# [String], [Int], [DateTime], etc.

# Default values can be assigned to some, all or none of the named
# parameters with the "=" sign.  Defaults can be overwritten by
# passing in values for some or all of the parameters.

param ([String] $word = "Cat", [Int] $number = 3)
$word * $number


