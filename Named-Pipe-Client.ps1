#################################################################################################
# This script demos the use of named pipes.  Run named-pipe-server.ps1 first, then this one.
# Requires .NET Framework 3.5 SP1 or later.
# For more information, see:
#   http://msdn.microsoft.com/en-us/library/system.io.pipes.namedpipeclientstream.aspx
#   http://blogs.msdn.com/b/bclteam/archive/2006/12/07/introducing-pipes-justin-van-patten.aspx
#   Get the pipelist.exe tool from http://www.microsoft.com/sysinternals
#################################################################################################



# These are some of the constants used with named pipes:
#[System.IO.Pipes.PipeDirection]::In             = 1
#[System.IO.Pipes.PipeDirection]::Out            = 2
#[System.IO.Pipes.PipeDirection]::InOut          = 3
#[System.IO.Pipes.PipeTransmissionMode]::Byte    = 0
#[System.IO.Pipes.PipeTransmissionMode]::Message = 1



# Create a named pipe client object:
$computer = "."         # A period means local computer, but can be remote instead.
$pipename = "poshpipe"  # Name of the named pipe to use, must be unique.
$direction = 3          # InOut can both send and receive.
$pipeclient = new-object System.IO.Pipes.NamedPipeClientStream -arg @($computer, $pipename, $direction)

# Connect to named pipe and change from byte mode to message mode.
$pipeclient.Connect()
$pipeclient.ReadMode = [System.IO.Pipes.PipeTransmissionMode]::Message

# Create array into which data from pipe can be read.
$buffer = new-object System.Byte[] -arg 10000

# Now fill that array by reading the pipe, keeping a counter of bytes copied.
# The arguments are: array to fill, beginning index, number of bytes to copy.
$counter = $pipeclient.Read($buffer,0,$buffer.count)

# Trim off the unfilled portion of the buffer array.
$buffer = $buffer[0..($counter - 1)]

# Cast byte array into a character array, join into a single string, then print.
[char[]] $buffer -join ""

















## Optionally, you can read data from the pipe byte-by-byte instead.
# $pipeclient.ReadMode = [System.IO.Pipes.PipeTransmissionMode]::Byte
# $reader = new-object System.IO.StreamReader -arg @($pipeclient)
# while (($temp = $reader.ReadLine()) -ne $null) { $temp + "`n" } 
