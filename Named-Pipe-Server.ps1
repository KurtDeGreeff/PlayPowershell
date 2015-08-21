#################################################################################################
# This script demos the use of named pipes.  Run this script first, then named-pipe-client.ps1.
# Requires .NET Framework 3.5 SP1 or later.
# For more information, see:
#   http://msdn.microsoft.com/en-us/library/system.io.pipes.namedpipeserverstream.aspx
#   http://blogs.msdn.com/b/bclteam/archive/2006/12/07/introducing-pipes-justin-van-patten.aspx
#   Get the pipelist.exe tool from http://www.microsoft.com/sysinternals
#################################################################################################



# These are some of the constants used with named pipes:
#[System.IO.Pipes.PipeDirection]::In             = 1
#[System.IO.Pipes.PipeDirection]::Out            = 2
#[System.IO.Pipes.PipeDirection]::InOut          = 3
#[System.IO.Pipes.PipeTransmissionMode]::Byte    = 0
#[System.IO.Pipes.PipeTransmissionMode]::Message = 1



# Create a named pipe server object to accept inbound connections.
$pipename = "poshpipe"  # Name of the named pipe to use, must be unique.
$direction = 3          # InOut, can both send and receive.
$max = 1                # Max number of instances of named pipe.
$mode = 1               # Transmission mode is message (1) or byte-by-byte (0)
$pipeserver = new-object System.IO.Pipes.NamedPipeServerStream -arg @($pipename, $direction, $max, $mode) 

"Will wait forever until a client connects to this pipe..."
$pipeserver.WaitForConnection() 
"The client has connected, writing data!"

# Write data to the pipe, to be read by the client.
$writer = new-object System.IO.StreamWriter -arg @($pipeserver)
$writer.AutoFlush = $true   #Flush buffer to stream after every Write().
$writer.Write("This string was read from the pipe named " + $pipename)

# Now remove the named pipe and clean up.
$pipeserver.Close()

 