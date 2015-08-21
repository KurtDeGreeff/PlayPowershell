################################################################################################
# Purpose: This function demonstrates how to listen on a TCP port.
#  Output: Outputs an array of raw bytes, which can be saved to a file using the 
#          "set-content -encoding byte" command, or, if you use the -ToAscii switch
#          with the function, it will output the ASCII text translation instead.  
#   Notes: This is just to get you started, see the System.Net.Sockets documentation.
################################################################################################
param ([Int32] $port = 9999, [Switch] $ToAscii)




function ListenOnTcpPortOnce ([Int32] $port = 9999, [Switch] $ToAscii)
{
    $TcpListener = new-object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Any, $port)
    Trap { "Error listening on TCP port " + $port + ":`n" + $_ ; return  }
    
    $TcpListener.Start()   #Listen on port, place new connections into queue.

    $IntSize = $TcpListener.Server.ReceiveBufferSize      #How many bytes max buffered up at a time.
    $ByteArray = new-object System.Byte[] -arg $IntSize   #Create local buffer of that max size.

    $TcpClient = $TcpListener.AcceptTcpClient()           #Wait here until there is a live inbound connection, then 
                                                          # move connection out of queue into $TcpClient.
                                                          
    $NetworkStream = $TcpClient.GetStream()               #Get the stream of inbound/outbound bytes for this TCP
                                                          # for reading/sending bytes of data.    

    Do                                                    #Now loop through and process the bytes received...
    {  
        $NumBytesRead = $NetworkStream.Read($ByteArray, 0, $ByteArray.Length)   #Read inbound bytes into buffer.
        if ($ToAscii) 
        { $(new-object System.Text.AsciiEncoding).GetString( $ByteArray[0..($NumBytesRead - 1)] ) }  #ASCII translation.
        else 
        { $ByteArray[0..($NumBytesRead - 1)] }                                                       #Emit raw bytes.
    } While ($NetworkStream.DataAvailable)                #Data being sent might be larger than local buffer.

    $TcpClient.Close()    #Closes this particular TCP connection.
    $TcpListener.Stop()   #Stops listening on the port entirely.  
}






#Demo the function...
if ($toascii) { ListenOnTcpPortOnce -port $port -toascii}
else  { ListenOnTcpPortOnce -port $port }


