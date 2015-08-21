# Command line samples
# "C:\temp\testSrc" "C:\temp\testDst" /xd "C:\temp\testSrc\Local\Adobe" /xf *.txt /V /xf *.test /A /M /S /CREATE /LEV:2 /A+:RSH
# "C:\temp\testSrc" "C:\temp\testDst" /xd "C:\temp\testSrc\Local\Adobe" /xf *.txt /V /VV:"c:\temp\log.txt" /xf *.test  /E /SECFIX /PURGE
# "C:\temp\testSrc" "C:\temp\testDst" *.txt *.jpg *.dll *.exe /xd "C:\temp\testSrc\Local\Adobe" /xf *.txt /V /VV:"c:\temp\log.txt" /xf *.test  /E /SECFIX /PURGE

<################################################################################>
<##                                                                            ##>
<##      RoboPowerCopy  -  http://robopowercopy.codeplex.com                   ##>
<##          written by:                                                       ##>
<##            * Ingo Karstein (http://ikarstein.wordpress.com)                ##>
<##                                                                            ##>
<##      This script is released under Microsoft Public Licence                ##>
<##          that can be downloaded here:                                      ##>
<##          http://www.microsoft.com/opensource/licenses.mspx#Ms-PL           ##>
<##                                                                            ##>
<##      This script was created using PowerGUI. (http://www.powergui.org)     ##>
<##                                                                            ##>
<##                                                                            ##>
<################################################################################>

<# ROBOCOPY REFERENCE

THE FOLLOWING LINES OF TEXT ARE TAKEN FROM http://ss64.com/nt/robocopy.html
THE CONTENT IS RELEASED UNDER 
	Attribution-Non-Commercial-Share Alike 2.0 UK: England & Wales


Robust File and Folder Copy.
By default Robocopy will only copy a file if the source and destination have different time stamps or different file sizes.

Syntax
      ROBOCOPY source_folder destination_folder [file(s)_to_copy] [options]

Key
   file(s)_to_copy : A list of files or a wildcard.
                          (defaults to copying *.*)

  Source options
                /S : Copy Subfolders.
                /E : Copy Subfolders, including Empty Subfolders.
 /COPY:copyflag[s] : What to COPY (default is /COPY:DAT)
                      (copyflags : D=Data, A=Attributes, T=Timestamps
                       S=Security=NTFS ACLs, O=Owner info, U=aUditing info).
              /SEC : Copy files with SECurity (equivalent to /COPY:DATS).
          /DCOPY:T : Copy Directory Timestamps. ##
          /COPYALL : Copy ALL file info (equivalent to /COPY:DATSOU).
           /NOCOPY : Copy NO file info (useful with /PURGE).

                /A : Copy only files with the Archive attribute set.
                /M : like /A, but remove Archive attribute from source files.
            /LEV:n : Only copy the top n LEVels of the source tree.

         /MAXAGE:n : MAXimum file AGE - exclude files older than n days/date.
         /MINAGE:n : MINimum file AGE - exclude files newer than n days/date.
                     (If n < 1900 then n = no of days, else n = YYYYMMDD date).

              /FFT : Assume FAT File Times (2-second date/time granularity).
              /256 : Turn off very long path (> 256 characters) support.

   Copy options
                /L : List only - don't copy, timestamp or delete any files.
              /MOV : MOVe files (delete from source after copying).
             /MOVE : Move files and dirs (delete from source after copying).

                /Z : Copy files in restartable mode (survive network glitch).
                /B : Copy files in Backup mode.
               /ZB : Use restartable mode; if access denied use Backup mode.
            /IPG:n : Inter-Packet Gap (ms), to free bandwidth on slow lines.

              /R:n : Number of Retries on failed copies - default is 1 million.
              /W:n : Wait time between retries - default is 30 seconds.
              /REG : Save /R:n and /W:n in the Registry as default settings.
              /TBD : Wait for sharenames To Be Defined (retry error 67).

   Destination options

    /A+:[RASHCNET] : Set file Attribute(s) on destination files + add.
    /A-:[RASHCNET] : UnSet file Attribute(s) on destination files - remove.
              /FAT : Create destination files using 8.3 FAT file names only.

           /CREATE : CREATE directory tree structure + zero-length files only.
              /DST : Compensate for one-hour DST time differences ##
            /PURGE : Delete dest files/folders that no longer exist in source.
              /MIR : MIRror a directory tree - equivalent to /PURGE plus all subfolders (/E)

   Logging options
                /L : List only - don't copy, timestamp or delete any files.
               /NP : No Progress - don't display % copied.
         /LOG:file : Output status to LOG file (overwrite existing log).
        /LOG+:file : Output status to LOG file (append to existing log).
                     UNILOG and UNILOG+ will output to a unicode logfile ##
               /TS : Include Source file Time Stamps in the output.
               /FP : Include Full Pathname of files in the output.
               /NS : No Size - don't log file sizes.
               /NC : No Class - don't log file classes.
              /NFL : No File List - don't log file names.
              /NDL : No Directory List - don't log directory names.
              /TEE : Output to console window, as well as the log file.
              /NJH : No Job Header.
              /NJS : No Job Summary.

 Repeated Copy Options
            /MON:n : MONitor source; run again when more than n changes seen.
            /MOT:m : MOnitor source; run again in m minutes Time, if changed.

     /RH:hhmm-hhmm : Run Hours - times when new copies may be started.
               /PF : Check run hours on a Per File (not per pass) basis.

 Job Options
      /JOB:jobname : Take parameters from the named JOB file.
     /SAVE:jobname : SAVE parameters to the named job file
             /QUIT : QUIT after processing command line (to view parameters). 
             /NOSD : NO Source Directory is specified.
             /NODD : NO Destination Directory is specified.
               /IF : Include the following Files.

Advanced options you'll probably never use
           /EFSRAW : Copy any encrypted files using EFS RAW mode.##
           /MT[:n] : Multithreaded copying, n = no. of threads to use (1-128) ###
                     default = 8 threads, not compatible with /IPG and /EFSRAW
                     The use of /LOG is recommended for better performance.

           /SECFIX : FIX file SECurity on all files, even skipped files.
           /TIMFIX : FIX file TIMes on all files, even skipped files.

               /XO : eXclude Older - if destination file exists and is the same date
                     or newer than the source - don't bother to overwrite it.
         /XC | /XN : eXclude Changed | Newer files
         /XX | /XL : eXclude eXtra | Lonely files and dirs. 
                     An "extra" file is present in destination but not source, 
                     excluding extras will delete from destination. 
                     A "lonely" file is present in source but not destination
                     excluding lonely will prevent any new files being added to the destination.

/XF file [file]... : eXclude Files matching given names/paths/wildcards.
/XD dirs [dirs]... : eXclude Directories matching given names/paths.
                     XF and XD can be used in combination  e.g.
                     ROBOCOPY c:\source d:\dest /XF *.doc *.xls /XD c:\unwanted /S 

   /IA:[RASHCNETO] : Include files with any of the given Attributes
   /XA:[RASHCNETO] : eXclude files with any of the given Attributes
               /IS : Include Same, overwrite files even if they are already the same.
               /IT : Include Tweaked files.
               /XJ : eXclude Junction points. (normally included by default).

            /MAX:n : MAXimum file size - exclude files bigger than n bytes.
            /MIN:n : MINimum file size - exclude files smaller than n bytes.
         /MAXLAD:n : MAXimum Last Access Date - exclude files unused since n.
         /MINLAD:n : MINimum Last Access Date - exclude files used since n.
                     (If n < 1900 then n = n days, else n = YYYYMMDD date).

            /BYTES : Print sizes as bytes.
                /X : Report all eXtra files, not just those selected & copied.
                /V : Produce Verbose output log, showing skipped files.
              /ETA : Show Estimated Time of Arrival of copied files.
## = New Option in Vista (XP027) all other options on this page are for the XP version of Robocopy (XP010) 
### = New Option in Windows 7 and Windows 2008 R2

Robocopy EXIT CODES

File Attributes [RASHCNETO]

 R – Read only 
 A – Archive 
 S – System 
 H – Hidden
 C – Compressed 
 N – Not content indexed
 E – Encrypted 
 T – Temporary
 O - Offline
If either the source or desination are a "quoted long foldername" do not include a trailing backslash as this will be treated as an escape character, i.e. "C:\some path\" will fail but "C:\some path\\" or "C:\some path\." or "C:\some path" will work.

Robocopy will fail to copy files that are 'locked' by other users or applications, limiting the number of retries with /R:0 will speed up large jobs.

By copying only the files that have changed, robocopy can be used to backup very large volumes. 
To limit the network bandwidth used by robocopy, specify the Inter-Packet Gap parameter /IPG:n 
This will send packets of 64 KB each followed by a delay of n Milliseconds.

ROBOCOPY will accept UNC pathnames including UNC pathnames over 256 characters long.

/REG Writes to the registry at HKCU\Software\Microsoft\ResKit\Robocopy

/B (backup mode) will allow Robocopy to override file and folder permission settings (ACLs).

All versions of Robocopy will copy security information (ACLs) for directories, version XP010 will not copy file security changes unless the file itself has also changed, this greatly improves performance.

To run ROBOCOPY under a non-administrator account will require backup files privilege, to copy security information auditing privilege is also required, plus of course you need at least read access to the files and folders.

The Windows Server 2003 Resource Kit Tools include Robocopy XP010, this can be run on NT 4/ Windows 2000. Robocopy does not run on Windows 95, or NT 3.5. (RoboCopy is a Unicode application).

Robocopy 'Jobs' and the 'MOnitor source' option provide an alternative to setting up a Scheduled Task to run a batchfile with a RoboCopy command.

Examples:

Copy files from one server to another (auto skip files already in the destination)

ROBOCOPY \\Server1\reports \\Server2\backup *.doc /S
List files over 32 MBytes in size:

ROBOCOPY C:\work /MAX:33554432 /L
Move files over 14 days old: (note the MOVE option will fail if any files are open and locked.)

ROBOCOPY C:\work C:\destination /move /minage:14
Backup a Server 

The script below copies data from FileServ1 to FileServ2, the destination holds a full mirror along with file security info. When run regularly to synchronize the source and destination, robocopy will only copy those files that have changed (change in time stamp or size.)

@ECHO OFF
SETLOCAL

SET _source=\\FileServ1\e$\users

SET _dest=\\FileServ2\e$\BackupUsers

SET _what=/COPYALL /B /SEC /MIR
:: /COPYALL :: COPY ALL file info
:: /B :: copy files in Backup mode. 
:: /SEC :: copy files with SECurity
:: /MIR :: MIRror a directory tree 

SET _options=/R:0 /W:0 /LOG:MyLogfile.txt /NFL /NDL
:: /R:n :: number of Retries
:: /W:n :: Wait time between retries
:: /LOG :: Output log file
:: /NFL :: No file logging
:: /NDL :: No dir logging

ROBOCOPY %_source% %_dest% %_what% %_options%

Run two robocopy jobs at the same time with START /Min

Start /Min "Job one" Robocopy \\FileServA\C$\Database1 \\FileServeBackupA\c$\Backups
Start /Min "Job two" Robocopy \\FileServB\C$\Database2 \\FileServeBackupB\c$\Backups
Bugs
Version XP026 returns a success errorlevel even when it fails.

“One, a robot may not injure a human being, or through inaction, allow a human being to come to harm” - Isaac Asimov, Laws of Robotics from I. Robot, 1950

#>


#region rerun variables cleanup
	function cleanupVariables() {
		$oldVar = (Get-Variable -Name "varList@Start" -ErrorAction SilentlyContinue).value
		$nVar = @("varList@Start")
		Get-Variable | % {
			if ( $_.Value -is [System.IO.Stream] -or $_.Value -is [System.IO.StreamWriter] -or 
			     $_.Value -is [System.IO.StreamReader] -or $_.Value -is [System.IO.TextWriter]  -or 
				 $_.Value -is [System.IO.TextReader] ) {
				try{
					if( $_.Value -ne $null ) {
						$_.Value.Close()
						$_.Value = $null
					}
				} finally {
					Remove-Variable -Name $_.Name -Force -ErrorAction SilentlyContinue
				}
			}
			if( $oldVar -ne $null -and $oldVar -inotcontains $_.Name ) {
				Remove-Variable -Name $_.Name -ErrorAction SilentlyContinue -Force -Scope Global
				Remove-Variable -Name $_.Name -ErrorAction SilentlyContinue -Force -Scope Script
			} else {
				$nVar += @($_.Name)
			}
		}
		if( $oldVar -eq $null ) {
			Set-Variable -Name "varList@Start" -Value $nVar -Force -Scope Global -ErrorAction SilentlyContinue
		}
		Remove-Variable -Name "nVar" -Force -ErrorAction SilentlyContinue
		Remove-Variable -Name "oldVar" -Force -ErrorAction SilentlyContinue	
	}
	cleanupVariables
#endregion
	
#region internal config
	$global:scriptCulture = [System.Globalization.CultureInfo]::GetCultureInfo(1033)
    $global:roboPowerCopyVersion = New-Object System.Version(0,1,0,1) 
	$global:startDateTime = [DateTime]::Now
	$global:startDateTimeStr = $startDateTime.ToString("ddd MMMM dd HH:mm:ss yyyy", $scriptCulture)
    $global:roboPowerCopyVersionDate = [DateTime]"2011.05.29"
	$global:whileCopyTimestamp = [System.DateTime]::FromFileTimeUtc(119599992000000000) # 1980/01/01 00:00:00
	$global:chunkSize = 10 * 1024 * 1024
	$global:hashAlg = "System.Security.Cryptography.SHA256"
	$global:useParallelProcessing = $true
	$global:verboseMemory = New-Object System.Text.StringBuilder
	Remove-Variable "VerboseStream" -Force -ErrorAction SilentlyContinue
	$global:infoCopiedFileCnt = 0
	$global:infoCopiedDirCnt = 0
	$global:infoCopiedFileSize = 0
	$global:infoSkippedFileCnt = 0
	$global:infoSkippedDirCnt = 0
	$global:infoSkippedFileSize = 0
	$global:infoDeletedFileCnt = 0
	$global:infoDeletedDirCnt = 0
	$global:infoDeletedFileSize = 0
	$global:infoErrorFileCnt = 0
	$global:infoErrorFileSize = 0
#endregion


#region default settings
	$global:srcDir = ""
	$global:dstDir = ""
	$global:filesToCopy = @("*.*") 

	$global:verboseOutput = $false
	$global:verboseOutputAppend = $false
	$global:detailedOutput = $false 
	$global:verify=$false
	$global:checksumBeforeCopy = $false  
	$global:overwrite=$false
	$global:percentProgress = $true
	$global:restartableMode = $false
	$global:maxRetryCount = 1000000
	$global:waitBeforeRetry = 30
	$global:recursive = $false
	$global:excludeDir = @()
	$global:excludeFile = @()
	$global:maxCopyLevel = -1
	$global:excludeEmptySubfolders = $false 
	$global:excludeSymbolicLinks = $false
	$global:excludeLinkedFiles = $false
	$global:excludeLinkedDirectories = $false
	$global:onlyCreateStructure = $false
	$global:attribsRemoveOnDest = -1
	$global:attribsAddOnDest = [System.IO.FileAttributes]::Archive
	$global:showFileSizeInBytes = $false
	$global:purge = $false                 
	$global:excludeChangedFiles = $false	#Not implemented
	$global:excludeOlderFiles = $false
	$global:excludeNewerFiles = $false		#Not implemented
	$global:excludeExtraFiles = $false		#Not implemented
	$global:excludeLonelyFiles = $false	#Not implemented
	$global:copyAttributes = $true		
	$global:copyData = $true
	$global:copyDirectoryTimestamps = $false
	$global:copyTimestamps = $true			
	$global:copySecurity = $false
	$global:copyAuditInfo = $false		
	$global:copyOwner = $false			
	$global:maxage = -1
	$global:minage = -1
	$global:onlyIfArchive = $false
	$global:removeArchiveAttribOnSource = $false
	$global:minLastAccessDate = -1
	$global:maxLastAccessDate = -1
	$global:minSize = -1					
	$global:maxSize = -1		
	$global:fixtime = $false				
	$global:fixsec = $false				
	$global:includeAttribs = 0xFFFFFFFF	
	$global:excludeAttribs = 0				
	$global:longPathSupport = $true
#endregion

#region type: RoboPowerCopyInfo
	Add-Type -ErrorAction SilentlyContinue -ReferencedAssemblies "Microsoft.VisualBasic" -Language CSharp -IgnoreWarnings -TypeDefinition @"
		//This C# code was written by Ingo Karstein for the RoboPowerCopy script
		using System;
		using System.IO;
		using System.Reflection;
		using System.Runtime;
		using System.Runtime.Serialization;
		using System.Runtime.Serialization.Formatters.Binary;

		[Serializable()]
		public class RoboPowerCopyInfo {
		    public string Header = "RoboPowerCopy_By_ikarstein";
		    public System.Version Version = new System.Version(1,0,0,0); 
		    public DateTime LastWriteTime = DateTime.MinValue;
			public DateTime SourceFileLastWriteTimeUtc = DateTime.MinValue;
			public long SourceFileLastLength = -1;
			public DateTime SourceFileCreationTimeUtc = DateTime.MinValue;
			public long NextWritePosition = 0;
	      	
			private string _copyOp = "";
			
			public string copyOp {
				get {
					return _copyOp.Trim();
				}
				set {
					_copyOp = value.PadRight(25,' ').Substring(0, 25);
				}
			}
		
			public byte[] ToArray() {
			   	MemoryStream ms = new MemoryStream();
			   	try {
			    	BinaryFormatter s = new BinaryFormatter();
					s.Serialize(ms, this);
					ms.Flush();
					byte[] b = ms.ToArray();
					return b;
			   	} catch {
			   		throw;
			  	}
		   		finally {
		     		ms.Close();
		   		}
			}
		
			public bool FromArray(byte[] data) {
				MemoryStream ms = new MemoryStream(data);
				try {
					BinaryFormatter s = new BinaryFormatter();
					s.Binder = new DeserializationBinder();
					RoboPowerCopyInfo tmp = (RoboPowerCopyInfo)s.Deserialize(ms);
					if( tmp.Header != this.Header || !System.Version.Equals(tmp.Version,this.Version) ) {
						return false;
					} else {
						this.LastWriteTime = tmp.LastWriteTime;
						this.NextWritePosition = tmp.NextWritePosition;
						this.SourceFileLastWriteTimeUtc = tmp.SourceFileLastWriteTimeUtc;
						this.SourceFileLastLength = tmp.SourceFileLastLength;
						this.SourceFileCreationTimeUtc = tmp.SourceFileCreationTimeUtc;
						
						return true;
					}
				} catch(Exception ex) {
					return false;
				}
				finally {
					ms.Close();
				}
			}

			public static bool TypeAvailable() {
				return true;
			}
	  }
	  
	  	sealed class DeserializationBinder : SerializationBinder 
	  	{
		    public override Type BindToType(string assemblyName, string typeName) 
		    {
		        Type typeToDeserialize = null;

				if( typeName == "RoboPowerCopyInfo" ) {		
			        typeToDeserialize = Type.GetType("RoboPowerCopyInfo");
				} else {
			        typeToDeserialize = Type.GetType(String.Format("{0}", typeName, assemblyName));
				}

		        return typeToDeserialize;
		    }
		}
"@

	$temp = New-Object RoboPowerCopyInfo
	$headerLength = $temp.ToArray().Length

#endregion

#region type: LongPathSupport
	#Write-Warning -WarningAction Continue -Message "LongPathSupport not inline!!!"
	#$c1 = (Get-Content "C:\Source\RoboPowerCopyTests\CopyFileSec\LongPathSupport.cs" -Encoding UTF8)
	#$classes = [string]::Join("`r`n", $c1)
#	Add-Type -ErrorAction SilentlyContinue -ReferencedAssemblies ("System.Windows.Forms") -Language CSharp -IgnoreWarnings -TypeDefinition $classes
	Add-Type -ErrorAction SilentlyContinue -ReferencedAssemblies ("System.Windows.Forms") -Language CSharp -IgnoreWarnings -TypeDefinition @"
		// Created by Ingo Karstein (ikarstein) for RoboPowerCopy
		// See http://robopowercopy.codeplex.com

		using System;
		using System.Collections.Generic;
		using System.Text;
		using System.Runtime.InteropServices;
		using Microsoft.Win32.SafeHandles;
		using System.Reflection;
		using System.Security;
		using System.Security.Permissions;
		using System.Runtime;
		using System.Security.AccessControl;
		using System.Diagnostics;


		public static class LongPathSupport
		{
			// Adapted from diffrent sources, e.g.
			//   http://blogs.msdn.com/b/bclteam/archive/2007/03/26/long-paths-in-net-part-2-of-3-long-path-workarounds-kim-hamilton.aspx
			//   http://support.microsoft.com/kb/175512

			internal static IntPtr INVALID_HANDLE_VALUE = new IntPtr(-1);
			internal static int FILE_ATTRIBUTE_DIRECTORY = 0x00000010;
			internal const int MaxPath = 0x7d00;

			[StructLayout(LayoutKind.Sequential)]
			internal struct FILETIME
			{
				internal uint dwLowDateTime;
				internal uint dwHighDateTime;
			};

			[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
			internal struct WIN32_FIND_DATA
			{
				internal WIN32_FILEATTRIBUTES dwFileAttributes;
				internal FILETIME ftCreationTime;
				internal FILETIME ftLastAccessTime;
				internal FILETIME ftLastWriteTime;
				internal int nFileSizeHigh;
				internal int nFileSizeLow;
				internal int dwReserved0;
				internal int dwReserved1;
				[MarshalAs(UnmanagedType.ByValTStr, SizeConst = MaxPath)]
				internal string cFileName;
				// not using this
				[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 14)]
				internal string cAlternate;
			}

			[Flags]
			public enum WIN32_FILEACCESS : uint
			{
				GenericRead = 0x80000000,
				GenericWrite = 0x40000000,
				GenericExecute = 0x20000000,
				GenericAll = 0x10000000,
			}

			[Flags]
			public enum WIN32_FILESHARE : uint
			{
				None = 0x00000000,
				Read = 0x00000001,
				Write = 0x00000002,
				Delete = 0x00000004,
			}

			public enum WIN32_CREATIONDISPOSITION : uint
			{
				New = 1,
				CreateAlways = 2,
				OpenExisting = 3,
				OpenAlways = 4,
				TruncateExisting = 5,
			}

			[Flags]
			public enum WIN32_FILEATTRIBUTES : uint
			{
				Readonly = 0x00000001,
				Hidden = 0x00000002,
				System = 0x00000004,
				Directory = 0x00000010,
				Archive = 0x00000020,
				Device = 0x00000040,
				Normal = 0x00000080,
				Temporary = 0x00000100,
				SparseFile = 0x00000200,
				ReparsePoint = 0x00000400,
				Compressed = 0x00000800,
				Offline = 0x00001000,
				NotContentIndexed = 0x00002000,
				Encrypted = 0x00004000,
				Write_Through = 0x80000000,
				Overlapped = 0x40000000,
				NoBuffering = 0x20000000,
				RandomAccess = 0x10000000,
				SequentialScan = 0x08000000,
				DeleteOnClose = 0x04000000,
				BackupSemantics = 0x02000000,
				PosixSemantics = 0x01000000,
				OpenReparsePoint = 0x00200000,
				OpenNoRecall = 0x00100000,
				FirstPipeInstance = 0x00080000
			}

			[StructLayout(LayoutKind.Sequential)]
			public struct SECURITY_ATTRIBUTES
			{
				public int nLength;
				public IntPtr lpSecurityDescriptor;
				public int bInheritHandle;
			}

			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, EntryPoint = "DeleteFile", SetLastError = true)]
			[return: MarshalAs(UnmanagedType.Bool)]
			private static extern bool RemoveFile(string lpFileName);

			[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
			private static extern SafeFileHandle CreateFile(
				string lpFileName,
				WIN32_FILEACCESS dwDesiredAccess,
				WIN32_FILESHARE dwShareMode,
				IntPtr lpSecurityAttributes,
				WIN32_CREATIONDISPOSITION dwCreationDisposition,
				WIN32_FILEATTRIBUTES dwFlagsAndAttributes,
				IntPtr hTemplateFile);

			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			internal static extern IntPtr FindFirstFile(string lpFileName, out
																								WIN32_FIND_DATA lpFindFileData);

			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			internal static extern bool FindNextFile(IntPtr hFindFile, out
																								WIN32_FIND_DATA lpFindFileData);

			[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
			[return: MarshalAs(UnmanagedType.Bool)]
			internal static extern bool FindClose(IntPtr hFindFile);

			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			[return: MarshalAs(UnmanagedType.Bool)]
			private static extern bool CreateDirectory(string lpPathName,
			   IntPtr lpSecurityAttributes);

			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			static extern bool RemoveDirectory(string lpPathName);

			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			private static extern bool SetFileAttributes(string lpFileName, uint dwFileAttributes);

			[Flags]
			public enum FindType
			{
				Files = 0x1,
				Directories = 0x2
			}

			[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
			[return: MarshalAs(UnmanagedType.U4)]
			private static extern int GetLongPathName(
				[MarshalAs(UnmanagedType.LPTStr)]
								string lpszShortPath,
						[MarshalAs(UnmanagedType.LPTStr)]
								StringBuilder lpszLongPath,
						[MarshalAs(UnmanagedType.U4)]
								int cchBuffer);


			[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
			static extern uint GetFullPathName(string lpFileName, uint nBufferLength,
			   [Out] StringBuilder lpBuffer, [Out] StringBuilder lpFilePart);

			[DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true, EntryPoint="EncryptFile")]
			[return: MarshalAs(UnmanagedType.Bool)]
			static extern bool W32EncryptFile(string filename);

			[DllImport("Advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode, EntryPoint = "DecryptFile")]
			static extern bool W32DecryptFile(string lpFileName, uint dwReserved);

			public static void DeleteFile(string fileName)
			{
				if (!SetFileAttributes(fileName, 0))
					throw new Exception(LastError());
				if (!RemoveFile(fileName))
					throw new Exception(LastError());
			}

			public static void DeleteDirectory(string dirName)
			{
				if (!RemoveDirectory(dirName))
					throw new Exception(LastError());
			}

			public static string Combine(string path1, string path2)
			{
				if ((path1 == null) || (path2 == null))
				{
					throw new ArgumentException("Arguments invalid");
				}

				if (!CheckInvalidPathChars(path1) || !CheckInvalidPathChars(path2))
					throw new ArgumentException("Invalid Characters in path");

				if (path2.Length == 0)
				{
					return path1;
				}
				if (path1.Length == 0)
				{
					return path2;
				}
				if (IsPathRooted(path2))
				{
					return path2;
				}
				char ch = path1[path1.Length - 1];
				if (((ch != System.IO.Path.DirectorySeparatorChar) && (ch != System.IO.Path.AltDirectorySeparatorChar)) && (ch != System.IO.Path.VolumeSeparatorChar))
				{
					return (path1 + System.IO.Path.DirectorySeparatorChar + path2);
				}
				return (path1 + path2);
			}

			public static bool IsPathRooted(string path)
			{
				if (path != null)
				{
					if (!CheckInvalidPathChars(path))
						throw new ArgumentException("Path contains invalid characters.");
					int length = path.Length;
					if (((length >= 1) && ((path[0] == System.IO.Path.DirectorySeparatorChar) || (path[0] == System.IO.Path.AltDirectorySeparatorChar))) || ((length >= 2) && (path[1] == System.IO.Path.VolumeSeparatorChar)))
					{
						return true;
					}
				}
				return false;
			}

			public static bool CreateDirectory(string directory)
			{
				return CreateDirectory(directory, IntPtr.Zero);
			}

			public static System.IO.FileStream Open(string path, System.IO.FileAccess access, System.IO.FileMode mode, System.IO.FileShare share)
			{
				WIN32_FILEACCESS fa = WIN32_FILEACCESS.GenericAll;
				switch (access)
				{
					case System.IO.FileAccess.Read: fa = WIN32_FILEACCESS.GenericRead; break;
					case System.IO.FileAccess.Write: fa = WIN32_FILEACCESS.GenericWrite; break;
					case System.IO.FileAccess.ReadWrite: fa = WIN32_FILEACCESS.GenericRead | WIN32_FILEACCESS.GenericWrite; break;
				}

				WIN32_CREATIONDISPOSITION cd = WIN32_CREATIONDISPOSITION.CreateAlways;
				switch (mode)
				{
					case System.IO.FileMode.Append: cd = WIN32_CREATIONDISPOSITION.OpenExisting; break;
					case System.IO.FileMode.Create: cd = WIN32_CREATIONDISPOSITION.New; break;
					case System.IO.FileMode.CreateNew: cd = WIN32_CREATIONDISPOSITION.CreateAlways; break;
					case System.IO.FileMode.Open: cd = WIN32_CREATIONDISPOSITION.OpenExisting; break;
					case System.IO.FileMode.OpenOrCreate: cd = WIN32_CREATIONDISPOSITION.OpenAlways; break;
					case System.IO.FileMode.Truncate: cd = WIN32_CREATIONDISPOSITION.TruncateExisting; break;
				}

				WIN32_FILESHARE fs = WIN32_FILESHARE.None;
				switch (share)
				{
					case System.IO.FileShare.Delete: fs = WIN32_FILESHARE.Delete; break;
					case System.IO.FileShare.Inheritable: fs = WIN32_FILESHARE.None; break;
					case System.IO.FileShare.None: fs = WIN32_FILESHARE.None; break;
					case System.IO.FileShare.Read: fs = WIN32_FILESHARE.Read; break;
					case System.IO.FileShare.Write: fs = WIN32_FILESHARE.Write; break;
					case System.IO.FileShare.ReadWrite: fs = WIN32_FILESHARE.Read | WIN32_FILESHARE.Write; break;
				}

				SafeFileHandle sfh = CreateFile(path, fa, fs, IntPtr.Zero, cd, 0, IntPtr.Zero);

				if (!sfh.IsClosed && !sfh.IsInvalid)
				{
					System.IO.FileStream stream = new System.IO.FileStream(sfh, access);
					if (mode == System.IO.FileMode.Append)
					{
						stream.Seek(0, System.IO.SeekOrigin.End);
					}
					return stream;
				}

				return null;
			}



			public static List<string> FindFilesAndDirs(string dirName, FindType types, bool recursive)
			{
				List<string> results = new List<string>();
				List<string> subResults = new List<string>();
				WIN32_FIND_DATA findData;
				IntPtr findHandle = FindFirstFile(dirName + @"\*", out findData);

				if (findHandle != INVALID_HANDLE_VALUE)
				{
					bool found;
					do
					{
						string currentFileName = findData.cFileName;

						if (((int)findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) != 0)
						{
							if (currentFileName != "." && currentFileName != "..")
							{
								if (recursive)
								{
									List<string> childResults = FindFilesAndDirs(System.IO.Path.Combine(dirName, currentFileName), types, recursive);

									subResults.AddRange(childResults);
								}
								if ((types & FindType.Directories) == FindType.Directories)
								{
									results.Add(System.IO.Path.Combine(dirName, currentFileName));
								}
							}
						}
						else
						{
							if ((types & FindType.Files) == FindType.Files)
							{
								results.Add(System.IO.Path.Combine(dirName, currentFileName));
							}
						}

						found = FindNextFile(findHandle, out findData);
					}
					while (found);
				}

				FindClose(findHandle);
				results.InsertRange(0, subResults);
				return results;
			}

			public static bool FileExists(string fileName)
			{
				System.IO.FileAttributes? x = AttributeHelper.GetAttributes(fileName);
				if (x != null)
					return (((int)x & (int)System.IO.FileAttributes.Directory) == 0);

				return false;


				/*WIN32_FIND_DATA findData;
				IntPtr findHandle = IntPtr.Zero;
				try
				{
					findHandle = FindFirstFile(fileName, out findData);

					if (findHandle == INVALID_HANDLE_VALUE)
						return false;

					if (((int)findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) != 0)
						return false;

					string currentFileName = findData.cFileName;
					if (fileName.EndsWith(currentFileName, StringComparison.InvariantCultureIgnoreCase))
						return true;

					return false;
				}
				finally
				{
					if (findHandle != IntPtr.Zero)
						FindClose(findHandle);
				}
				*/
			}

			public static long FileLength(string fileName)
			{
				WIN32_FIND_DATA findData;
				IntPtr findHandle = IntPtr.Zero;
				try
				{
					findHandle = FindFirstFile(fileName, out findData);

					if (findHandle == INVALID_HANDLE_VALUE)
						return -1;

					if (((int)findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) != 0)
						return -1;

					string currentFileName = findData.cFileName;
					if (fileName.EndsWith(currentFileName, StringComparison.InvariantCultureIgnoreCase))
						return ((findData.nFileSizeHigh << 0x20) | (findData.nFileSizeLow & ((long)0xffffffffL)));

					return -1;
				}
				finally
				{
					if (findHandle != IntPtr.Zero)
						FindClose(findHandle);
				}
			}

			public static bool DirectoryExists(string dirName)
			{
				System.IO.FileAttributes? x = AttributeHelper.GetAttributes(dirName);
				if (x != null)
					return (((int)x & (int)System.IO.FileAttributes.Directory) > 0);

				return false;

				/*dirName = dirName.TrimEnd(new char[] { '\\' });

				WIN32_FIND_DATA findData;
				IntPtr findHandle = IntPtr.Zero;
				try
				{
					findHandle = FindFirstFile(dirName, out findData);

					if (findHandle == INVALID_HANDLE_VALUE)
						return false;

					if (((int)findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) == 0)
						return false;

					string currentDirName = findData.cFileName;
					if (dirName.EndsWith(currentDirName, StringComparison.InvariantCultureIgnoreCase) || dirName.Length == 2)
						return true;

					return false;
				}
				finally
				{
					if (findHandle != IntPtr.Zero)
						FindClose(findHandle);
				}
				 * */
			}

			public static bool TypeAvailable()
			{
				return true;
			}

			public static string LastError()
			{
				return new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error()).Message;
			}

			public static System.Security.Permissions.FileIOPermission GetFileIOPermission(System.Security.Permissions.FileIOPermissionAccess access, string path)
			{
				ConstructorInfo ci = typeof(System.Security.Permissions.FileIOPermission).GetConstructor(BindingFlags.NonPublic |
					BindingFlags.Instance, null, new Type[] { typeof(System.Security.Permissions.FileIOPermissionAccess), 
														   typeof(string[]), typeof(bool), typeof(bool) }, null);
				System.Security.Permissions.FileIOPermission fiop = (System.Security.Permissions.FileIOPermission)ci.Invoke(new object[] { access, new string[] { path }, false, false });
				return fiop;
			}

			public static string GetFullName(string path)
			{
				StringBuilder tmpFullName = new StringBuilder(LongPathSupport.MaxPath * 2 + 2);
				uint ret = GetFullPathName(path, MaxPath * 2 + 2, tmpFullName, null);
				if (ret > MaxPath || ret == 0)
					return string.Empty;
				else
					return tmpFullName.ToString();
			}

			internal static bool CheckInvalidPathChars(string path)
			{
				int start = 0;
				if (path.StartsWith(@"\\?\"))
					start = 4;
				for (int i = start; i < path.Length; i++)
				{
					int c = path[i];
					if (((c == 0x22) || (c == 60)) || (((c == 0x3e) || (c == 0x7c)) || (c < 0x20)))
					{
						return false;
					}
				}
				return true;
			}

			internal static bool IsDirectorySeparator(char c)
			{
				if (c != System.IO.Path.DirectorySeparatorChar)
				{
					return (c == System.IO.Path.AltDirectorySeparatorChar);
				}
				return true;
			}

			internal static int GetRootLength(string path)
			{
				if (!CheckInvalidPathChars(path))
					return -1;

				int mode = 0;
				int length = path.Length;
				if ((length >= 1) && IsDirectorySeparator(path[0]))
				{
					mode = 1;
					if ((length >= 2) && IsDirectorySeparator(path[1]))
					{
						mode = 2;
						int startIndex = 2;
						while ((mode < length) && (!IsDirectorySeparator(path[mode]) || (--startIndex > 0)))
						{
							mode++;
						}
					}
					return mode;
				}
				if ((length >= 2) && (path[1] == System.IO.Path.VolumeSeparatorChar))
				{
					mode = 2;
					if ((length >= 3) && IsDirectorySeparator(path[2]))
					{
						mode++;
					}
				}
				return mode;
			}

			public static bool EncryptFile(string fileName)
			{
				return EncryptFile(fileName);
			}

			public static bool DecryptFile(string fileName)
			{
				return DecryptFile(fileName);
			}
			
			public static string GetDirectoryName(string path)
			{
				if (path != null)
				{
					if (!CheckInvalidPathChars(path))
						return "?";

					path = GetFullName(path);
					int rootLength = GetRootLength(path);
					if (path.Length > rootLength)
					{
						int length = path.Length;
						if (length == rootLength)
						{
							return null;
						}
						while ((length > rootLength) && !IsDirectorySeparator(path[--length]))
						{
						}
						return path.Substring(0, length);
					}
				}
				return null;
			}


		}

		public class LongFileInfo
		{
			private string _name;
			private string _fullname;
			private int _prefixLen = 0;
			private DateTime _lastWriteTime;
			private DateTime _lastWriteTimeUtc;
			private DateTime _lastAccessTime;
			private DateTime _lastAccessTimeUtc;
			private DateTime _creationTime;
			private DateTime _creationTimeUtc;
			private System.IO.FileAttributes _attributes;


			[SecuritySafeCritical]
			public LongFileInfo(string fileName)
			{
				_fullname = LongPathSupport.GetFullName(fileName);

				if (!_fullname.StartsWith(@"\\?\"))
				{
					if (_fullname.StartsWith(@"\\"))
					{
						_fullname = @"\\?\UNC\" + _fullname.Substring(2);
						_prefixLen = 8;
					}
					else
					{
						_fullname = @"\\?\" + _fullname;
						_prefixLen = 4;
					}
				}
				else
				{
					if (_fullname.StartsWith(@"\\?\UNC\"))
						_prefixLen = 8;
					else
						_prefixLen = 4;
				}

				if (string.IsNullOrEmpty(_fullname)) throw new Exception("Path invalid");

				_name = System.IO.Path.GetFileName(_fullname);
				Refresh();
			}

			[SecuritySafeCritical]
			public System.IO.FileStream Open(System.IO.FileMode mode)
			{
				return this.Open(mode, System.IO.FileAccess.ReadWrite, System.IO.FileShare.None);
			}

			[SecuritySafeCritical]
			public System.IO.FileStream Open(System.IO.FileMode mode, System.IO.FileAccess access)
			{
				return this.Open(mode, access, System.IO.FileShare.None);
			}

			[SecuritySafeCritical]
			public System.IO.FileStream Open(System.IO.FileMode mode, System.IO.FileAccess access, System.IO.FileShare share)
			{
				return LongPathSupport.Open(_fullname, access, mode, share);
			}

			[SecuritySafeCritical]
			public System.IO.FileStream OpenRead()
			{
				return LongPathSupport.Open(_fullname, System.IO.FileAccess.Read, System.IO.FileMode.Open, System.IO.FileShare.Read);
			}

			[SecuritySafeCritical]
			public System.IO.StreamReader OpenText()
			{
				return new System.IO.StreamReader(_fullname, Encoding.UTF8, true, 0x400);
			}

			[SecuritySafeCritical]
			public System.IO.FileStream OpenWrite()
			{
				return LongPathSupport.Open(_fullname, System.IO.FileAccess.Write, System.IO.FileMode.OpenOrCreate, System.IO.FileShare.None);
			}


			[SecuritySafeCritical]
			public System.IO.FileStream Create()
			{
				return LongPathSupport.Open(_fullname, System.IO.FileAccess.Write, System.IO.FileMode.Create, System.IO.FileShare.None);
			}

			[SecuritySafeCritical]
			public System.IO.StreamWriter CreateText()
			{
				return new System.IO.StreamWriter(LongPathSupport.Open(_fullname, System.IO.FileAccess.Write, System.IO.FileMode.Create, System.IO.FileShare.None));
			}


			public override string ToString()
			{
				return _fullname;
			}

			public void Delete()
			{
				LongPathSupport.DeleteFile(_fullname);
			}

			public LongDirectoryInfo Directory
			{
				[SecuritySafeCritical]
				get
				{
					string directoryName = this.DirectoryName;
					if (directoryName == null)
					{
						return null;
					}
					return new LongDirectoryInfo(directoryName);
				}
			}

			public string DirectoryName
			{
				[SecuritySafeCritical]
				get
				{
					string directoryName = LongPathSupport.GetDirectoryName(_fullname);
					if (directoryName != null)
					{
						//LongPathSupport.GetFileIOPermission(FileIOPermissionAccess.PathDiscovery, directoryName).Demand();
					}
					return directoryName;
				}
			}

			public bool Exists
			{
				[SecuritySafeCritical]
				get
				{
					return LongPathSupport.FileExists(_fullname);
				}
			}

			public string Name
			{
				get
				{
					return this._name;
				}
			}

			public string FullName
			{
				get
				{
					return _fullname.Substring(_prefixLen);
				}
			}

			public string FullQualifiedName
			{
				get
				{
					return _fullname;
				}
			}

			public long Length
			{
				[SecuritySafeCritical]
				get
				{
					return LongPathSupport.FileLength(_fullname);
				}
			}

			public void Refresh()
			{
				if (!Exists)
				{
					DateTime minUtc = new DateTime(1601, 01, 01, 00, 00, 00, 00, DateTimeKind.Utc);
					DateTime minLocal = minUtc.ToLocalTime();
					_creationTime = _lastAccessTime = _lastWriteTime = minLocal;
					_creationTimeUtc = _lastAccessTimeUtc = _lastWriteTimeUtc = minUtc;
					_attributes = (System.IO.FileAttributes)(-1);
				}
				else
				{
					if (!FileTimeHelper.GetFileTimes(_fullname, out _creationTime, out _lastAccessTime, out _lastWriteTime))
						throw new System.IO.IOException("Could not get file times");
					if (!FileTimeHelper.GetFileTimesUtc(_fullname, out _creationTimeUtc, out _lastAccessTimeUtc, out _lastWriteTimeUtc))
						throw new System.IO.IOException("Could not get file times");
					System.IO.FileAttributes? _tmp = (System.IO.FileAttributes)AttributeHelper.GetAttributes(_fullname);
					if (_tmp == null)
						throw new System.IO.IOException("Could not get file attributes");
					_attributes = (System.IO.FileAttributes)_tmp;
				}
			}



			public static bool TypeAvailable()
			{
				return true;
			}

			public DateTime LastWriteTime
			{
				get
				{
					return _lastWriteTime;
				}
				set
				{
					_lastWriteTime = value;
					if (!FileTimeHelper.SetFileTimes(_fullname, null, null, _lastWriteTime))
						throw new System.IO.IOException("Could not set LastWriteTime");
				}
			}
			public DateTime LastWriteTimeUtc
			{
				get
				{
					return _lastWriteTimeUtc;
				}
				set
				{
					_lastWriteTimeUtc = value;
					if (!FileTimeHelper.SetFileTimesUtc(_fullname, null, null, _lastWriteTimeUtc))
						throw new System.IO.IOException("Could not set LastWriteTimeUtc");
				}
			}
			public DateTime LastAccessTime
			{
				get
				{
					return _lastAccessTime;
				}
				set
				{
					_lastAccessTime = value;
					if (!FileTimeHelper.SetFileTimes(_fullname, null, _lastAccessTime, null))
						throw new System.IO.IOException("Could not set LastAccessTime");
				}
			}
			public DateTime LastAccessTimeUtc
			{
				get
				{
					return _lastAccessTimeUtc;
				}
				set
				{
					_lastAccessTimeUtc = value;
					if (!FileTimeHelper.SetFileTimesUtc(_fullname, null, _lastAccessTimeUtc, null))
						throw new System.IO.IOException("Could not set LastAccessTimeUtc");
				}
			}
			public DateTime CreationTime
			{
				get
				{
					return _creationTime;
				}
				set
				{
					_creationTime = value;
					if (!FileTimeHelper.SetFileTimes(_fullname, _creationTime, null, null))
						throw new System.IO.IOException("Could not set CreationTime");
				}
			}
			public DateTime CreationTimeUtc
			{
				get
				{
					return _creationTimeUtc;
				}
				set
				{
					_creationTimeUtc = value;
					if (!FileTimeHelper.SetFileTimesUtc(_fullname, _creationTimeUtc, null, null))
						throw new System.IO.IOException("Could not set CreationTimeUtc");
				}
			}
			public System.IO.FileAttributes Attributes
			{
				get
				{
					return _attributes;
				}
				set
				{
					_attributes = value;
					if (!AttributeHelper.SetAttributes(_fullname, _attributes))
						throw new System.IO.IOException("Could not set file attributes");
				}
			}


		}



		public class LongDirectoryInfo
		{
			private string _fullname;
			private string _name;
			private int _prefixLen = 0;
			private DateTime _lastWriteTime;
			private DateTime _lastWriteTimeUtc;
			private DateTime _lastAccessTime;
			private DateTime _lastAccessTimeUtc;
			private DateTime _creationTime;
			private DateTime _creationTimeUtc;

			[SecuritySafeCritical]
			public LongDirectoryInfo(string directoryName)
			{
				_fullname = LongPathSupport.GetFullName(directoryName);
				if (string.IsNullOrEmpty(_fullname))
					throw new System.IO.IOException("Could not determine full name");

				if (!_fullname.StartsWith(@"\\?\"))
				{
					if (_fullname.StartsWith(@"\\"))
					{
						_fullname = @"\\?\UNC\" + _fullname.Substring(2);
						_prefixLen = 8;
					}
					else
					{
						_fullname = @"\\?\" + _fullname;
						_prefixLen = 4;
					}
				}
				else
				{
					if (_fullname.StartsWith(@"\\?\UNC\"))
						_prefixLen = 8;
					else
						_prefixLen = 4;
				}

				//if (_fullname.Length - _prefixLen == 3)
				//{
				//    _fullname = _fullname.Substring(_prefixLen);
				//}

				if (string.IsNullOrEmpty(_fullname)) throw new Exception(LongPathSupport.LastError());

				_name = System.IO.Path.GetFileName(_fullname);

				Refresh();
			}

			[SecuritySafeCritical]
			public LongDirectoryInfo[] GetDirectories(string searchPattern)
			{
				List<LongDirectoryInfo> ret = new List<LongDirectoryInfo>();
				searchPattern = "^" + System.Text.RegularExpressions.Regex.Escape(searchPattern).Replace("\\*", ".*").Replace("\\?", ".") + "$";
				System.Text.RegularExpressions.Regex r = new System.Text.RegularExpressions.Regex(searchPattern);
				foreach (string dir in LongPathSupport.FindFilesAndDirs(_fullname, LongPathSupport.FindType.Directories, false))
				{
					LongDirectoryInfo dir2 = new LongDirectoryInfo(dir);
					if (r.IsMatch(dir2.Name))
						ret.Add(dir2);
				}
				return ret.ToArray();
			}

			[SecuritySafeCritical]
			public LongDirectoryInfo[] GetDirectories()
			{
				return GetDirectories("*");
			}

			[SecuritySafeCritical]
			public LongFileInfo[] GetFiles(string searchPattern)
			{
				List<LongFileInfo> ret = new List<LongFileInfo>();
				searchPattern = "^" + System.Text.RegularExpressions.Regex.Escape(searchPattern).Replace("\\*", ".*").Replace("\\?", ".") + "$";
				System.Text.RegularExpressions.Regex r = new System.Text.RegularExpressions.Regex(searchPattern);
				foreach (string dir in LongPathSupport.FindFilesAndDirs(_fullname, LongPathSupport.FindType.Files, false))
				{
					LongFileInfo lfi = new LongFileInfo(dir);
					if (r.IsMatch(lfi.Name))
						ret.Add(new LongFileInfo(dir));
				}
				return ret.ToArray();
			}

			[SecuritySafeCritical]
			public LongFileInfo[] GetFiles()
			{

				return GetFiles("*");
			}

			public string FullName
			{
				get
				{
					return _fullname.Substring(_prefixLen);
				}
			}

			public string FullQualifiedName
			{
				get
				{
					return _fullname;
				}
			}

			public string Name
			{
				get
				{
					return this._name;
				}
			}

			public bool Exists
			{
				[SecuritySafeCritical]
				get
				{
					return LongPathSupport.DirectoryExists(_fullname);
				}
			}

			public void Delete(bool recursive)
			{
				if (recursive)
				{
					List<string> files = LongPathSupport.FindFilesAndDirs(_fullname, LongPathSupport.FindType.Files, true);
					foreach (string s in files)
						LongPathSupport.DeleteFile(s);

					List<string> dirs = LongPathSupport.FindFilesAndDirs(_fullname, LongPathSupport.FindType.Directories, true);
					foreach (string s in dirs)
						LongPathSupport.DeleteDirectory(s);
				}

				LongPathSupport.DeleteDirectory(_fullname);
			}

			public DateTime LastWriteTime
			{
				get
				{
					return _lastWriteTime;
				}
				set
				{
					_lastWriteTime = value;
					if (!FileTimeHelper.SetDirectoryTimesUtc(_fullname, null, null, _lastWriteTime))
						throw new System.IO.IOException("Could not set LastWriteTime");
				}
			}
			public DateTime LastWriteTimeUtc
			{
				get
				{
					return _lastWriteTimeUtc;
				}
				set
				{
					_lastWriteTimeUtc = value;
					if (!FileTimeHelper.SetDirectoryTimesUtc(_fullname, null, null, _lastWriteTimeUtc))
						throw new System.IO.IOException("Could not set LastWriteTimeUtc");
				}
			}
			public DateTime LastAccessTime
			{
				get
				{
					return _lastAccessTime;
				}
				set
				{
					_lastAccessTime = value;
					if (!FileTimeHelper.SetDirectoryTimesUtc(_fullname, null, _lastAccessTime, null))
						throw new System.IO.IOException("Could not set LastAccessTime");
				}
			}
			public DateTime LastAccessTimeUtc
			{
				get
				{
					return _lastAccessTimeUtc;
				}
				set
				{
					_lastAccessTimeUtc = value;
					if (!FileTimeHelper.SetDirectoryTimesUtc(_fullname, null, _lastAccessTimeUtc, null))
						throw new System.IO.IOException("Could not set LastAccessTimeUtc");
				}
			}
			public DateTime CreationTime
			{
				get
				{
					return _creationTime;
				}
				set
				{
					_creationTime = value;
					if (!FileTimeHelper.SetDirectoryTimesUtc(_fullname, _creationTime, null, null))
						throw new System.IO.IOException("Could not set CreationTime");
				}
			}
			public DateTime CreationTimeUtc
			{
				get
				{
					return _creationTimeUtc;
				}
				set
				{
					_creationTimeUtc = value;
					if (!FileTimeHelper.SetDirectoryTimesUtc(_fullname, _creationTimeUtc, null, null))
						throw new System.IO.IOException("Could not set CreationTimeUtc");
				}
			}

			public void Refresh()
			{
				if (!Exists)
				{
					DateTime minUtc = new DateTime(1601, 01, 01, 00, 00, 00, 00, DateTimeKind.Utc);
					DateTime minLocal = minUtc.ToLocalTime();
					_creationTime = _lastAccessTime = _lastWriteTime = minLocal;
					_creationTimeUtc = _lastAccessTimeUtc = _lastWriteTimeUtc = minUtc;
				}
				else
				{
					if (!FileTimeHelper.GetDirectoryTimes(_fullname, out _creationTime, out _lastAccessTime, out _lastWriteTime))
						throw new System.IO.IOException("Could not get file times");
					if (!FileTimeHelper.GetDirectoryTimesUtc(_fullname, out _creationTimeUtc, out _lastAccessTimeUtc, out _lastWriteTimeUtc))
						throw new System.IO.IOException("Could not get file times");
				}
			}

			public LongDirectoryInfo Parent
			{
				[SecuritySafeCritical]
				get
				{
					string fullPath = _fullname;
					if ((fullPath.Length > 3) && (fullPath.EndsWith(System.IO.Path.DirectorySeparatorChar.ToString()) || fullPath.EndsWith(System.IO.Path.AltDirectorySeparatorChar.ToString())))
					{
						fullPath = fullPath.Substring(0, fullPath.Length - 1);
					}

					string directoryName = LongPathSupport.GetDirectoryName(fullPath);
					if (directoryName == null)
					{
						return null;
					}

					LongDirectoryInfo info = new LongDirectoryInfo(directoryName);
					//new FileIOPermission(FileIOPermissionAccess.PathDiscovery | FileIOPermissionAccess.Read, info.demandDir, false, false).Demand();
					return info;
				}

			}

			public void Create()
			{
				try
				{
					if (!Parent.Exists)
						Parent.Create();
				}
				catch
				{
					throw new System.IO.IOException("Could not create directory");
				}

				if (!LongPathSupport.CreateDirectory(_fullname))
					throw new System.IO.IOException("Could not create directory");
			}

			public static bool TypeAvailable()
			{
				return true;
			}
		}

		public static class FileTimeHelper
		{
			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			private static extern bool GetFileTime(SafeFileHandle hFile, ref FILETIME lpCreationTime,
			   ref FILETIME lpLastAccessTime, ref FILETIME lpLastWriteTime);

			[StructLayout(LayoutKind.Sequential)]
			private struct FILETIME
			{
				public uint dwLowDateTime;
				public uint dwHighDateTime;
			}

			[StructLayout(LayoutKind.Sequential)]
			private struct SYSTEMTIME
			{
				[MarshalAs(UnmanagedType.U2)]
				public short Year;
				[MarshalAs(UnmanagedType.U2)]
				public short Month;
				[MarshalAs(UnmanagedType.U2)]
				public short DayOfWeek;
				[MarshalAs(UnmanagedType.U2)]
				public short Day;
				[MarshalAs(UnmanagedType.U2)]
				public short Hour;
				[MarshalAs(UnmanagedType.U2)]
				public short Minute;
				[MarshalAs(UnmanagedType.U2)]
				public short Second;
				[MarshalAs(UnmanagedType.U2)]
				public short Milliseconds;

				public SYSTEMTIME(DateTime dt, DateTimeKind kind)
				{
					if (kind == DateTimeKind.Utc)
						dt = dt.ToUniversalTime();  // SetSystemTime expects the SYSTEMTIME in UTC

					Year = (short)dt.Year;
					Month = (short)dt.Month;
					DayOfWeek = (short)dt.DayOfWeek;
					Day = (short)dt.Day;
					Hour = (short)dt.Hour;
					Minute = (short)dt.Minute;
					Second = (short)dt.Second;
					Milliseconds = (short)dt.Millisecond;
				}

				public DateTime ToUTC()
				{
					DateTime t = new DateTime(this.Year, this.Month, this.Day, this.Hour, this.Minute, this.Second, this.Milliseconds, DateTimeKind.Utc);
					return t;
				}

				public DateTime ToLocal()
				{
					DateTime t = new DateTime(this.Year, this.Month, this.Day, this.Hour, this.Minute, this.Second, this.Milliseconds, DateTimeKind.Local);
					return t;
				}
			}

			[DllImport("kernel32.dll", CallingConvention = CallingConvention.Winapi, CharSet = CharSet.Unicode, SetLastError = true)]
			static extern bool FileTimeToSystemTime(ref FILETIME lpFileTime,
			   out SYSTEMTIME lpSystemTime);

			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			static extern bool SystemTimeToFileTime(ref SYSTEMTIME lpSystemTime,
			   out FILETIME lpFileTime);

			[Flags]
			public enum EFileAccess : uint
			{
				GenericRead = 0x80000000,
				GenericWrite = 0x40000000,
				GenericExecute = 0x20000000,
				GenericAll = 0x10000000,
			}

			[Flags]
			public enum EFileShare : uint
			{
				None = 0x00000000,
				Read = 0x00000001,
				Write = 0x00000002,
				Delete = 0x00000004,
			}

			public enum ECreationDisposition : uint
			{
				New = 1,
				CreateAlways = 2,
				OpenExisting = 3,
				OpenAlways = 4,
				TruncateExisting = 5,
			}

			[Flags]
			public enum EFileAttributes : uint
			{
				Readonly = 0x00000001,
				Hidden = 0x00000002,
				System = 0x00000004,
				Directory = 0x00000010,
				Archive = 0x00000020,
				Device = 0x00000040,
				Normal = 0x00000080,
				Temporary = 0x00000100,
				SparseFile = 0x00000200,
				ReparsePoint = 0x00000400,
				Compressed = 0x00000800,
				Offline = 0x00001000,
				NotContentIndexed = 0x00002000,
				Encrypted = 0x00004000,
				Write_Through = 0x80000000,
				Overlapped = 0x40000000,
				NoBuffering = 0x20000000,
				RandomAccess = 0x10000000,
				SequentialScan = 0x08000000,
				DeleteOnClose = 0x04000000,
				BackupSemantics = 0x02000000,
				PosixSemantics = 0x01000000,
				OpenReparsePoint = 0x00200000,
				OpenNoRecall = 0x00100000,
				FirstPipeInstance = 0x00080000
			}

			[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
			private static extern SafeFileHandle CreateFile(
				string lpFileName,
				EFileAccess dwDesiredAccess,
				EFileShare dwShareMode,
				IntPtr lpSecurityAttributes,
				ECreationDisposition dwCreationDisposition,
				EFileAttributes dwFlagsAndAttributes,
				IntPtr hTemplateFile);

			[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
			[return: MarshalAs(UnmanagedType.Bool)]
			private static extern bool CloseHandle(
				SafeFileHandle hObject
			);

			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			static extern bool SystemTimeToTzSpecificLocalTime(IntPtr
			   lpTimeZoneInformation, ref SYSTEMTIME lpUniversalTime,
			   out SYSTEMTIME lpLocalTime);

			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			static extern bool TzSpecificLocalTimeToSystemTime(IntPtr
			   lpTimeZoneInformation, ref SYSTEMTIME lpLocalTime,
			   out SYSTEMTIME lpUniversalTime);

			[StructLayout(LayoutKind.Sequential)]
			public struct SECURITY_ATTRIBUTES
			{
				public int nLength;
				public IntPtr lpSecurityDescriptor;
				public int bInheritHandle;
			}

			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			[return: MarshalAs(UnmanagedType.Bool)]
			static extern bool SetFileTime(SafeFileHandle hFile, IntPtr lpCreationTime, IntPtr lpLastAccessTime, IntPtr lpLastWriteTime);

			public static DateTime MinimumTime;
			public static DateTime MinimumTimeUtc;

			static FileTimeHelper()
			{
				MinimumTimeUtc = new DateTime(1601, 01, 01, 00, 00, 00, 00, DateTimeKind.Utc);
				MinimumTime = MinimumTimeUtc.ToLocalTime();
			}

			public static bool GetDirectoryTimesUtc(string DirectoryName, out DateTime CreationTimeUtc, out DateTime LastAccessTimeUtc, out DateTime LastWriteTimeUtc)
			{
				SafeFileHandle ptr = null;
				CreationTimeUtc = MinimumTimeUtc;
				LastAccessTimeUtc = MinimumTimeUtc;
				LastWriteTimeUtc = MinimumTimeUtc;


				try
				{
					ptr = CreateFile(DirectoryName + "\0", EFileAccess.GenericRead | EFileAccess.GenericWrite, EFileShare.Read | EFileShare.Write, IntPtr.Zero, ECreationDisposition.OpenExisting, EFileAttributes.BackupSemantics, IntPtr.Zero);
					if (ptr == null || ptr.IsInvalid || ptr.IsClosed)
						return false;

					return GetFileTimesUtc(ptr, out CreationTimeUtc, out LastAccessTimeUtc, out LastWriteTimeUtc);
				}
				catch (Exception e)
				{
					return false;
				}
				finally
				{
					if (ptr != null && !ptr.IsInvalid && !ptr.IsClosed)
						ptr.Dispose();
				}
			}

			public static bool GetDirectoryTimes(string DirectoryName, out DateTime CreationTime, out DateTime LastAccessTime, out DateTime LastWriteTime)
			{
				SafeFileHandle ptr = null;
				CreationTime = MinimumTime;
				LastAccessTime = MinimumTime;
				LastWriteTime = MinimumTime;

				try
				{
					ptr = CreateFile(DirectoryName + "\0", EFileAccess.GenericRead | EFileAccess.GenericWrite, EFileShare.Read | EFileShare.Write, IntPtr.Zero, ECreationDisposition.OpenExisting, EFileAttributes.BackupSemantics, IntPtr.Zero);
					if (ptr == null || ptr.IsInvalid || ptr.IsClosed)
						return false;

					return GetFileTimes(ptr, out CreationTime, out LastAccessTime, out LastWriteTime);
				}
				catch (Exception e)
				{
					return false;
				}
				finally
				{
					if (ptr != null && !ptr.IsInvalid && !ptr.IsClosed)
						ptr.Dispose();
				}
			}

			public static bool GetFileTimesUtc(string FileName, out DateTime CreationTimeUtc, out DateTime LastAccessTimeUtc, out DateTime LastWriteTimeUtc)
			{
				SafeFileHandle ptr = null;
				CreationTimeUtc = MinimumTimeUtc;
				LastAccessTimeUtc = MinimumTimeUtc;
				LastWriteTimeUtc = MinimumTimeUtc;

				try
				{
					ptr = CreateFile(FileName, EFileAccess.GenericRead, EFileShare.Read, IntPtr.Zero, ECreationDisposition.OpenExisting, EFileAttributes.Normal, IntPtr.Zero);
					if (ptr == null || ptr.IsInvalid || ptr.IsClosed)
						return false;

					return GetFileTimesUtc(ptr, out CreationTimeUtc, out LastAccessTimeUtc, out LastWriteTimeUtc);
				}
				catch (Exception e)
				{
					return false;
				}
				finally
				{
					if (ptr != null && !ptr.IsInvalid && !ptr.IsClosed)
						ptr.Dispose();
				}
			}

			public static bool GetFileTimesUtc(SafeFileHandle file, out DateTime CreationTimeUtc, out DateTime LastAccessTimeUtc, out DateTime LastWriteTimeUtc)
			{
				CreationTimeUtc = MinimumTimeUtc;
				LastAccessTimeUtc = MinimumTimeUtc;
				LastWriteTimeUtc = MinimumTimeUtc;

				if (file == null || file.IsInvalid || file.IsClosed)
					return false;

				FILETIME ftCreationTime = new FILETIME();
				FILETIME ftLastAccessTime = new FILETIME();
				FILETIME ftLastWriteTime = new FILETIME();
				try
				{
					if (GetFileTime(file, ref ftCreationTime, ref ftLastAccessTime, ref ftLastWriteTime) != true)
						Marshal.ThrowExceptionForHR(Marshal.GetHRForLastWin32Error());

					SYSTEMTIME sCreationTime, sLastAccessTime, sLastWriteTime;

					if (!FileTimeToSystemTime(ref ftCreationTime, out sCreationTime))
						return false;

					if (!FileTimeToSystemTime(ref ftLastAccessTime, out sLastAccessTime))
						return false;

					if (!FileTimeToSystemTime(ref ftLastWriteTime, out sLastWriteTime))
						return false;

					CreationTimeUtc = sCreationTime.ToUTC();
					LastAccessTimeUtc = sLastAccessTime.ToUTC();
					LastWriteTimeUtc = sLastWriteTime.ToUTC();

					return true;
				}
				catch (Exception e)
				{
					return false;
				}
				finally
				{
				}
			}

			public static bool GetFileTimes(string FileName, out DateTime CreationTime, out DateTime LastAccessTime, out DateTime LastWriteTime)
			{
				SafeFileHandle ptr = null;
				CreationTime = MinimumTime;
				LastAccessTime = MinimumTime;
				LastWriteTime = MinimumTime;

				try
				{
					ptr = CreateFile(FileName, EFileAccess.GenericRead, EFileShare.Read, IntPtr.Zero, ECreationDisposition.OpenExisting, EFileAttributes.Normal, IntPtr.Zero);
					if (ptr == null || ptr.IsInvalid || ptr.IsClosed)
						return false;

					return GetFileTimes(ptr, out CreationTime, out LastAccessTime, out LastWriteTime);
				}
				catch (Exception e)
				{
					return false;
				}
				finally
				{
					if (ptr != null && !ptr.IsInvalid && !ptr.IsClosed)
						ptr.Dispose();
				}
			}

			public static bool GetFileTimes(SafeFileHandle file, out DateTime CreationTime, out DateTime LastAccessTime, out DateTime LastWriteTime)
			{
				CreationTime = MinimumTime;
				LastAccessTime = MinimumTime;
				LastWriteTime = MinimumTime;

				if (file == null || file.IsInvalid || file.IsClosed)
					return false;

				FILETIME ftCreationTime = new FILETIME();
				FILETIME ftLastAccessTime = new FILETIME();
				FILETIME ftLastWriteTime = new FILETIME();
				try
				{
					if (GetFileTime(file, ref ftCreationTime, ref ftLastAccessTime, ref ftLastWriteTime) != true)
						Marshal.ThrowExceptionForHR(Marshal.GetHRForLastWin32Error());

					SYSTEMTIME sCreationTime, sLastAccessTime, sLastWriteTime;
					SYSTEMTIME slCreationTime, slLastAccessTime, slLastWriteTime;

					if (!FileTimeToSystemTime(ref ftCreationTime, out sCreationTime))
						return false;

					if (!FileTimeToSystemTime(ref ftLastAccessTime, out sLastAccessTime))
						return false;

					if (!FileTimeToSystemTime(ref ftLastWriteTime, out sLastWriteTime))
						return false;

					if (!SystemTimeToTzSpecificLocalTime(IntPtr.Zero, ref sCreationTime, out slCreationTime))
						return false;

					if (!SystemTimeToTzSpecificLocalTime(IntPtr.Zero, ref sLastAccessTime, out slLastAccessTime))
						return false;

					if (!SystemTimeToTzSpecificLocalTime(IntPtr.Zero, ref sLastWriteTime, out slLastWriteTime))
						return false;

					CreationTime = slCreationTime.ToLocal();
					LastAccessTime = slLastAccessTime.ToLocal();
					LastWriteTime = slLastWriteTime.ToLocal();
					return true;
				}
				catch (Exception e)
				{
					return false;
				}
				finally
				{
				}
			}

			public static bool SetDirectoryTimes(string DirectoryName, DateTime? creationTime, DateTime? lastAccessTime, DateTime? lastWriteTime)
			{
				SafeFileHandle ptr = null;
				try
				{
					ptr = CreateFile(DirectoryName + "\0", EFileAccess.GenericRead | EFileAccess.GenericWrite, EFileShare.Read | EFileShare.Write, IntPtr.Zero, ECreationDisposition.OpenExisting, EFileAttributes.BackupSemantics, IntPtr.Zero);

					if (ptr == null || ptr.IsInvalid || ptr.IsClosed)
						return false;

					return SetFileTimes(ptr, creationTime, lastAccessTime, lastWriteTime);
				}
				catch (Exception e)
				{
					return false;
				}
				finally
				{
					if (ptr != null && !ptr.IsInvalid && !ptr.IsClosed)
						ptr.Dispose();
				}
			}

			public static bool SetDirectoryTimesUtc(string DirectoryName, DateTime? creationTimeUtc, DateTime? lastAccessTimeUtc, DateTime? lastWriteTimeUtc)
			{
				SafeFileHandle ptr = null;
				try
				{
					ptr = CreateFile(DirectoryName + "\0", EFileAccess.GenericRead | EFileAccess.GenericWrite, EFileShare.Read | EFileShare.Write, IntPtr.Zero, ECreationDisposition.OpenExisting, EFileAttributes.BackupSemantics, IntPtr.Zero);

					if (ptr == null || ptr.IsInvalid || ptr.IsClosed)
						return false;

					return SetFileTimesUtc(ptr, creationTimeUtc, lastAccessTimeUtc, lastWriteTimeUtc);
				}
				catch (Exception e)
				{
					return false;
				}
				finally
				{
					if (ptr != null && !ptr.IsInvalid && !ptr.IsClosed)
						ptr.Dispose();
				}
			}

			public static bool SetFileTimes(string FileName, DateTime? creationTime, DateTime? lastAccessTime, DateTime? lastWriteTime)
			{
				SafeFileHandle ptr = null;
				try
				{
					ptr = CreateFile(FileName, EFileAccess.GenericWrite, EFileShare.Read, IntPtr.Zero, ECreationDisposition.OpenExisting, EFileAttributes.Normal, IntPtr.Zero);
					if (ptr == null || ptr.IsInvalid || ptr.IsClosed)
						return false;

					return SetFileTimes(ptr, creationTime, lastAccessTime, lastWriteTime);
				}
				catch (Exception e)
				{
					return false;
				}
				finally
				{
					if (ptr != null && !ptr.IsInvalid && !ptr.IsClosed)
						ptr.Dispose();
				}
			}

			public static bool SetFileTimes(SafeFileHandle file, DateTime? creationTime, DateTime? lastAccessTime, DateTime? lastWriteTime)
			{
				if (file == null || file.IsInvalid || file.IsClosed)
					return false;

				IntPtr iftCreationTime = IntPtr.Zero, iftLastAccessTime = IntPtr.Zero, iftLastWriteTime = IntPtr.Zero;
				try
				{
					FILETIME? ftCreationTime = null;
					FILETIME? ftLastAccessTime = null;
					FILETIME? ftLastWriteTime = null;

					if (creationTime != null)
					{
						DateTime ct = (DateTime)creationTime;
						if (ct >= MinimumTime)
						{

							SYSTEMTIME slCt = new SYSTEMTIME(ct, DateTimeKind.Local);
							SYSTEMTIME sCt;
							FILETIME fCt;

							if (!TzSpecificLocalTimeToSystemTime(IntPtr.Zero, ref slCt, out sCt))
								return false;

							if (!SystemTimeToFileTime(ref sCt, out fCt))
								return false;

							ftCreationTime = fCt;

							iftCreationTime = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(FILETIME)));
							Marshal.StructureToPtr(ftCreationTime, iftCreationTime, false);
						}
					}

					if (lastAccessTime != null)
					{
						DateTime lat = (DateTime)lastAccessTime;

						if (lat >= MinimumTime)
						{
							SYSTEMTIME slLat = new SYSTEMTIME(lat, DateTimeKind.Local);
							SYSTEMTIME sLat;
							FILETIME fLat;

							if (!TzSpecificLocalTimeToSystemTime(IntPtr.Zero, ref slLat, out sLat))
								return false;

							if (!SystemTimeToFileTime(ref sLat, out fLat))
								return false;

							ftLastAccessTime = fLat;

							iftLastAccessTime = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(FILETIME)));
							Marshal.StructureToPtr(ftLastAccessTime, iftLastAccessTime, false);
						}
					}

					if (lastWriteTime != null)
					{
						DateTime lwt = (DateTime)lastWriteTime;

						if (lwt >= MinimumTime)
						{

							SYSTEMTIME slLwt = new SYSTEMTIME(lwt, DateTimeKind.Local);
							SYSTEMTIME sLwt;
							FILETIME fLwt;

							if (!TzSpecificLocalTimeToSystemTime(IntPtr.Zero, ref slLwt, out sLwt))
								return false;

							if (!SystemTimeToFileTime(ref sLwt, out fLwt))
								return false;

							ftLastWriteTime = fLwt;

							iftLastWriteTime = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(FILETIME)));
							Marshal.StructureToPtr(ftLastWriteTime, iftLastWriteTime, false);
						}
					}

					if (SetFileTime(file, iftCreationTime, iftLastAccessTime, iftLastWriteTime) != true)
						Marshal.ThrowExceptionForHR(Marshal.GetHRForLastWin32Error());

					return true;
				}
				catch (Exception e)
				{
					return false;
				}
				finally
				{
					if (iftCreationTime != IntPtr.Zero)
						Marshal.FreeHGlobal(iftCreationTime);
					if (iftLastAccessTime != IntPtr.Zero)
						Marshal.FreeHGlobal(iftLastAccessTime);
					if (iftLastWriteTime != IntPtr.Zero)
						Marshal.FreeHGlobal(iftLastWriteTime);
				}
			}

			public static bool SetFileTimesUtc(string FileName, DateTime? creationTimeUtc, DateTime? lastAccessTimeUtc, DateTime? lastWriteTimeUtc)
			{
				SafeFileHandle ptr = null;
				try
				{
					ptr = CreateFile(FileName, EFileAccess.GenericWrite, EFileShare.Read, IntPtr.Zero, ECreationDisposition.OpenExisting, EFileAttributes.Normal, IntPtr.Zero);
					if (ptr == null || ptr.IsInvalid || ptr.IsClosed)
						return false;

					return SetFileTimesUtc(ptr, creationTimeUtc, lastAccessTimeUtc, lastWriteTimeUtc);
				}
				catch (Exception e)
				{
					return false;
				}
				finally
				{
					if (ptr != null && !ptr.IsInvalid && !ptr.IsClosed)
						ptr.Dispose();
				}
			}

			public static bool SetFileTimesUtc(SafeFileHandle file, DateTime? creationTimeUtc, DateTime? lastAccessTimeUtc, DateTime? lastWriteTimeUtc)
			{
				if (file == null || file.IsInvalid || file.IsClosed)
					return false;

				IntPtr iftCreationTime = IntPtr.Zero, iftLastAccessTime = IntPtr.Zero, iftLastWriteTime = IntPtr.Zero;
				try
				{
					FILETIME? ftCreationTime = null;
					FILETIME? ftLastAccessTime = null;
					FILETIME? ftLastWriteTime = null;

					if (creationTimeUtc != null)
					{
						DateTime ct = (DateTime)creationTimeUtc;
						if (ct >= MinimumTimeUtc)
						{

							SYSTEMTIME sCt = new SYSTEMTIME(ct, DateTimeKind.Utc);
							FILETIME fCt;

							if (!SystemTimeToFileTime(ref sCt, out fCt))
								return false;

							ftCreationTime = fCt;

							iftCreationTime = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(FILETIME)));
							Marshal.StructureToPtr(ftCreationTime, iftCreationTime, false);
						}
					}

					if (lastAccessTimeUtc != null)
					{
						DateTime lat = (DateTime)lastAccessTimeUtc;

						if (lat >= MinimumTimeUtc)
						{

							SYSTEMTIME sLat = new SYSTEMTIME(lat, DateTimeKind.Utc);
							FILETIME fLat;


							if (!SystemTimeToFileTime(ref sLat, out fLat))
								return false;

							ftLastAccessTime = fLat;

							iftLastAccessTime = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(FILETIME)));
							Marshal.StructureToPtr(ftLastAccessTime, iftLastAccessTime, false);
						}
					}

					if (lastWriteTimeUtc != null)
					{
						DateTime lwt = (DateTime)lastWriteTimeUtc;

						if (lwt >= MinimumTimeUtc)
						{
							SYSTEMTIME sLwt = new SYSTEMTIME(lwt, DateTimeKind.Utc);

							FILETIME fLwt;

							if (!SystemTimeToFileTime(ref sLwt, out fLwt))
								return false;

							ftLastWriteTime = fLwt;

							iftLastWriteTime = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(FILETIME)));
							Marshal.StructureToPtr(ftLastWriteTime, iftLastWriteTime, false);
						}
					}


					if (SetFileTime(file, iftCreationTime, iftLastAccessTime, iftLastWriteTime) != true)
						Marshal.ThrowExceptionForHR(Marshal.GetHRForLastWin32Error());

					return true;
				}
				catch (Exception e)
				{
					return false;
				}
				finally
				{
					if (iftCreationTime != IntPtr.Zero)
						Marshal.FreeHGlobal(iftCreationTime);
					if (iftLastAccessTime != IntPtr.Zero)
						Marshal.FreeHGlobal(iftLastAccessTime);
					if (iftLastWriteTime != IntPtr.Zero)
						Marshal.FreeHGlobal(iftLastWriteTime);
				}
			}

			public static bool TypeAvailable()
			{
				return true;
			}
		}


		public static class AttributeHelper
		{
			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			private static extern int SetFileAttributes(string lpFileName, uint dwFileAttributes);

			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			private static extern int GetFileAttributes(string lpFileName);

			public static System.IO.FileAttributes? GetAttributes(string fileName)
			{
				int ret = GetFileAttributes(fileName);
				if (ret == -1)
				{
					return null;
				}

				System.IO.FileAttributes res = 0;
				if ((ret & (int)LongPathSupport.WIN32_FILEATTRIBUTES.Archive) > 0)
					res |= System.IO.FileAttributes.Archive;
				if ((ret & (int)LongPathSupport.WIN32_FILEATTRIBUTES.Compressed) > 0)
					res |= System.IO.FileAttributes.Compressed;
				if ((ret & (int)LongPathSupport.WIN32_FILEATTRIBUTES.Device) > 0)
					res |= System.IO.FileAttributes.Device;

				if ((ret & (int)LongPathSupport.WIN32_FILEATTRIBUTES.Directory) > 0)
					res |= System.IO.FileAttributes.Directory;
				if ((ret & (int)LongPathSupport.WIN32_FILEATTRIBUTES.Encrypted) > 0)
					res |= System.IO.FileAttributes.Encrypted;
				if ((ret & (int)LongPathSupport.WIN32_FILEATTRIBUTES.Hidden) > 0)
					res |= System.IO.FileAttributes.Hidden;
				if ((ret & (int)LongPathSupport.WIN32_FILEATTRIBUTES.Normal) > 0)
					res |= System.IO.FileAttributes.Normal;
				if ((ret & (int)LongPathSupport.WIN32_FILEATTRIBUTES.NotContentIndexed) > 0)
					res |= System.IO.FileAttributes.NotContentIndexed;
				if ((ret & (int)LongPathSupport.WIN32_FILEATTRIBUTES.Offline) > 0)
					res |= System.IO.FileAttributes.Offline;
				if ((ret & (int)LongPathSupport.WIN32_FILEATTRIBUTES.Readonly) > 0)
					res |= System.IO.FileAttributes.ReadOnly;
				if ((ret & (int)LongPathSupport.WIN32_FILEATTRIBUTES.ReparsePoint) > 0)
					res |= System.IO.FileAttributes.ReparsePoint;
				if ((ret & (int)LongPathSupport.WIN32_FILEATTRIBUTES.SparseFile) > 0)
					res |= System.IO.FileAttributes.SparseFile;
				if ((ret & (int)LongPathSupport.WIN32_FILEATTRIBUTES.System) > 0)
					res |= System.IO.FileAttributes.System;
				if ((ret & (int)LongPathSupport.WIN32_FILEATTRIBUTES.Temporary) > 0)
					res |= System.IO.FileAttributes.Temporary;

				return res;
			}

			public static bool SetAttributes(string fileName, System.IO.FileAttributes attributes)
			{
				LongPathSupport.WIN32_FILEATTRIBUTES attr = 0;

				System.IO.FileAttributes res = 0;
				if (((int)attributes & (int)System.IO.FileAttributes.Archive) > 0)
					attr |= LongPathSupport.WIN32_FILEATTRIBUTES.Archive;
				if (((int)attributes & (int)System.IO.FileAttributes.Compressed) > 0)
					attr |= LongPathSupport.WIN32_FILEATTRIBUTES.Compressed;
				if (((int)attributes & (int)System.IO.FileAttributes.Device) > 0)
					attr |= LongPathSupport.WIN32_FILEATTRIBUTES.Device;

				if (((int)attributes & (int)System.IO.FileAttributes.Directory) > 0)
					attr |= LongPathSupport.WIN32_FILEATTRIBUTES.Directory;
				if (((int)attributes & (int)System.IO.FileAttributes.Encrypted) > 0)
					attr |= LongPathSupport.WIN32_FILEATTRIBUTES.Encrypted;
				if (((int)attributes & (int)System.IO.FileAttributes.Hidden) > 0)
					attr |= LongPathSupport.WIN32_FILEATTRIBUTES.Hidden;
				if (((int)attributes & (int)System.IO.FileAttributes.Normal) > 0)
					attr |= LongPathSupport.WIN32_FILEATTRIBUTES.Normal;
				if (((int)attributes & (int)System.IO.FileAttributes.NotContentIndexed) > 0)
					attr |= LongPathSupport.WIN32_FILEATTRIBUTES.NotContentIndexed;
				if (((int)attributes & (int)System.IO.FileAttributes.Offline) > 0)
					attr |= LongPathSupport.WIN32_FILEATTRIBUTES.Offline;
				if (((int)attributes & (int)System.IO.FileAttributes.ReadOnly) > 0)
					attr |= LongPathSupport.WIN32_FILEATTRIBUTES.Readonly;
				if (((int)attributes & (int)System.IO.FileAttributes.ReparsePoint) > 0)
					attr |= LongPathSupport.WIN32_FILEATTRIBUTES.ReparsePoint;
				if (((int)attributes & (int)System.IO.FileAttributes.SparseFile) > 0)
					attr |= LongPathSupport.WIN32_FILEATTRIBUTES.SparseFile;
				if (((int)attributes & (int)System.IO.FileAttributes.System) > 0)
					attr |= LongPathSupport.WIN32_FILEATTRIBUTES.System;
				if (((int)attributes & (int)System.IO.FileAttributes.Temporary) > 0)
					attr |= LongPathSupport.WIN32_FILEATTRIBUTES.Temporary;

				int ret =  SetFileAttributes(fileName, (uint)attr);
				return ret != 0;
			}

			public static bool CopyAttributes(string sourceFile, string destFile)
			{
				System.IO.FileAttributes? sourceAttr = GetAttributes(sourceFile);
				if (sourceAttr == null) return false;
				return SetAttributes(destFile, (System.IO.FileAttributes)sourceAttr);
			}

			public static bool AddAttributes(string fileName, System.IO.FileAttributes attributesToAdd)
			{
				System.IO.FileAttributes? attribs = GetAttributes(fileName);
				if (attribs == null) return false;
				attribs = (System.IO.FileAttributes)attribs | attributesToAdd;
				return SetAttributes(fileName, (System.IO.FileAttributes)attribs);
			}

			public static bool RemoveAttributes(string fileName, System.IO.FileAttributes attributesToRemove)
			{
				System.IO.FileAttributes? attribs = GetAttributes(fileName);
				if (attribs == null) return false;
				attribs = (System.IO.FileAttributes)attribs & (System.IO.FileAttributes)((uint)0xFFFFFFFF ^ (uint)attributesToRemove);
				return SetAttributes(fileName, (System.IO.FileAttributes)attribs);
			}

			public static bool RemoveAllAttributes(string fileName)
			{
				return SetAttributes(fileName, System.IO.FileAttributes.Normal);
			}

			public static bool TypeAvailable()
			{
				return true;
			}
		}

		public class CopySecurityHelper
		{

			[DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			static extern uint GetNamedSecurityInfo(
				string pObjectName,
				SE_OBJECT_TYPE ObjectType,
				SECURITY_INFORMATION SecurityInfo,
				out IntPtr pSidOwner,
				out IntPtr pSidGroup,
				out IntPtr pDacl,
				out IntPtr pSacl,
				out IntPtr pSecurityDescriptor);

			[DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			static extern uint SetNamedSecurityInfo(
				string pObjectName,
				SE_OBJECT_TYPE ObjectType,
				SECURITY_INFORMATION SecurityInfo,
				IntPtr psidOwner,
				IntPtr psidGroup,
				IntPtr pDacl,
				IntPtr pSacl);

			enum SE_OBJECT_TYPE
			{
				SE_UNKNOWN_OBJECT_TYPE = 0,
				SE_FILE_OBJECT,
				SE_SERVICE,
				SE_PRINTER,
				SE_REGISTRY_KEY,
				SE_LMSHARE,
				SE_KERNEL_OBJECT,
				SE_WINDOW_OBJECT,
				SE_DS_OBJECT,
				SE_DS_OBJECT_ALL,
				SE_PROVIDER_DEFINED_OBJECT,
				SE_WMIGUID_OBJECT,
				SE_REGISTRY_WOW64_32KEY
			}

			[Flags]
			enum SECURITY_INFORMATION : uint
			{
				OWNER_SECURITY_INFORMATION = 0x00000001,
				GROUP_SECURITY_INFORMATION = 0x00000002,
				DACL_SECURITY_INFORMATION = 0x00000004,
				SACL_SECURITY_INFORMATION = 0x00000008,
				UNPROTECTED_SACL_SECURITY_INFORMATION = 0x10000000,
				UNPROTECTED_DACL_SECURITY_INFORMATION = 0x20000000,
				PROTECTED_SACL_SECURITY_INFORMATION = 0x40000000,
				PROTECTED_DACL_SECURITY_INFORMATION = 0x80000000
			}

			[DllImport("Advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			private static extern bool ConvertStringSidToSid(String StringSid, ref IntPtr Sid);

			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			static extern IntPtr LocalFree(IntPtr hMem);

			[DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			private static extern bool LookupAccountSid(String lpSystemName, IntPtr Sid, System.Text.StringBuilder lpName, ref int cchName, System.Text.StringBuilder ReferencedDomainName, ref int cchReferencedDomainName, out int peUse);

			public static void SetFileOrFolderOwner(String objectName) //Note this is very basic and is silent on fail as I havent checked GetlastError and thrown an exception etc
			{
				IntPtr sidPtr = IntPtr.Zero;
				SECURITY_INFORMATION sFlags = SECURITY_INFORMATION.OWNER_SECURITY_INFORMATION;

				System.Security.Principal.NTAccount user = new System.Security.Principal.NTAccount("P1R4T3\\Harris");
				System.Security.Principal.SecurityIdentifier sid = (System.Security.Principal.SecurityIdentifier)user.Translate(typeof(System.Security.Principal.SecurityIdentifier));

				ConvertStringSidToSid(sid.ToString(), ref sidPtr);

				SetNamedSecurityInfo(objectName, SE_OBJECT_TYPE.SE_FILE_OBJECT, sFlags, sidPtr, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero);

				//Probably should release the IntPtr here to avoid memory leakage?????
			}

			public struct CopySecurityResult
			{
				public int resultCode; //0=OK, 1=Error in Get, 2=Error in Set, 3=Other Error
				public string errorMessageGET;
				public string errorMessageSET;
				public string errorMessageOther;
			}

			public static CopySecurityResult CopySecurity(System.IO.FileInfo src, System.IO.FileInfo dst, bool copyDACL, bool copySACL, bool copyOwner)
			{
				return CopySecurity(src.FullName, dst.FullName, copyDACL, copySACL, copyOwner);
			}
			public static CopySecurityResult CopySecurity(LongFileInfo src, LongFileInfo dst, bool copyDACL, bool copySACL, bool copyOwner)
			{
				return CopySecurity(src.FullQualifiedName, dst.FullQualifiedName, copyDACL, copySACL, copyOwner);
			}
			public static CopySecurityResult CopySecurity(string src, string dst, bool copyDACL, bool copySACL, bool copyOwner)
			{
				CopySecurityResult ret = new CopySecurityResult();

				SECURITY_INFORMATION secInf = 0;
				if (copyDACL)
					secInf = secInf | SECURITY_INFORMATION.GROUP_SECURITY_INFORMATION | SECURITY_INFORMATION.DACL_SECURITY_INFORMATION;
				if (copySACL)
					secInf = secInf | SECURITY_INFORMATION.GROUP_SECURITY_INFORMATION | SECURITY_INFORMATION.SACL_SECURITY_INFORMATION;
				if (copyOwner)
					secInf = secInf | SECURITY_INFORMATION.OWNER_SECURITY_INFORMATION;

				IntPtr pSidGroup, pSidOwner, pDacl, pSacl, pSecurityDescriptor = IntPtr.Zero;
				try
				{
					uint res1 = GetNamedSecurityInfo(src, SE_OBJECT_TYPE.SE_FILE_OBJECT,
							secInf, out pSidOwner, out pSidGroup, out pDacl, out pSacl, out pSecurityDescriptor);
					if (res1 != 0)
					{
						string err = new System.ComponentModel.Win32Exception((int)res1).Message;
						ret.resultCode = 1;
						ret.errorMessageOther = err;
					}
					else
					{
						uint res2 = SetNamedSecurityInfo(dst, SE_OBJECT_TYPE.SE_FILE_OBJECT, secInf, pSidOwner, pSidGroup, pDacl, pSacl);
						if (res2 != 0)
						{
							string err = new System.ComponentModel.Win32Exception((int)res2).Message;
							ret.resultCode = 2;
							ret.errorMessageOther = err;
						}
						else
						{
							ret.resultCode = 0;
						}
					}
				}
				catch (Exception ex)
				{
					ret.resultCode = 3;
					ret.errorMessageOther = ex.Message;
				}
				finally
				{
					if (pSecurityDescriptor != IntPtr.Zero)
						LocalFree(pSecurityDescriptor);
				}

				return ret;
			}

			public static bool TypeAvailable()
			{
				return true;
			}
		}

		//#####################################################################################
		//#The following code is taken from 
		//#   http://www.codeproject.com/KB/vista/ReparsePointID.aspx
		//#
		//#Thanks to the Dave Midgley for his work!


		public class ReparsePoint
		{
			// This is based on the code at http://www.flexhex.com/docs/articles/hard-links.phtml

			private const uint IO_REPARSE_TAG_MOUNT_POINT = 0xA0000003;		// Moiunt point or junction, see winnt.h
			private const uint IO_REPARSE_TAG_SYMLINK = 0xA000000C;			// SYMLINK or SYMLINKD (see http://wesnerm.blogs.com/net_undocumented/2006/10/index.html)
			private const UInt32 SE_PRIVILEGE_ENABLED = 0x00000002;
			private const string SE_BACKUP_NAME = "SeBackupPrivilege";
			private const uint FILE_FLAG_BACKUP_SEMANTICS = 0x02000000;
			private const uint FILE_FLAG_OPEN_REPARSE_POINT = 0x00200000;
			private const uint FILE_DEVICE_FILE_SYSTEM = 9;
			private const uint FILE_ANY_ACCESS = 0;
			private const uint METHOD_BUFFERED = 0;
			private const int MAXIMUM_REPARSE_DATA_BUFFER_SIZE = 16 * 1024;
			private const uint TOKEN_ADJUST_PRIVILEGES = 0x0020;
			private const int FSCTL_GET_REPARSE_POINT = 42;

			// This is the official version of the data buffer, see http://msdn2.microsoft.com/en-us/library/ms791514.aspx
			// not the one used at http://www.flexhex.com/docs/articles/hard-links.phtml
			[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
			private struct REPARSE_DATA_BUFFER
			{
				public uint ReparseTag;
				public short ReparseDataLength;
				public short Reserved;
				public short SubsNameOffset;
				public short SubsNameLength;
				public short PrintNameOffset;
				public short PrintNameLength;
				[MarshalAs(UnmanagedType.ByValArray, SizeConst = MAXIMUM_REPARSE_DATA_BUFFER_SIZE)]
				public char[] ReparseTarget;
			}

			[StructLayout(LayoutKind.Sequential)]
			private struct LUID
			{
				public UInt32 LowPart;
				public Int32 HighPart;
			}

			[StructLayout(LayoutKind.Sequential)]
			private struct LUID_AND_ATTRIBUTES
			{
				public LUID Luid;
				public UInt32 Attributes;
			}

			private struct TOKEN_PRIVILEGES
			{
				public UInt32 PrivilegeCount;
				[MarshalAs(UnmanagedType.ByValArray, SizeConst = 1)]		// !! think we only need one
				public LUID_AND_ATTRIBUTES[] Privileges;
			}

			[DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true, CharSet = CharSet.Unicode)]
			[return: MarshalAs(UnmanagedType.Bool)]
			static extern bool DeviceIoControl(
				IntPtr hDevice,
				uint dwIoControlCode,
				IntPtr lpInBuffer,
				uint nInBufferSize,
				//IntPtr lpOutBuffer, 
				out REPARSE_DATA_BUFFER outBuffer,
				uint nOutBufferSize,
				out uint lpBytesReturned,
				IntPtr lpOverlapped);

			[DllImport("Kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
			static extern IntPtr CreateFile(
				string fileName,
				[MarshalAs(UnmanagedType.U4)] System.IO.FileAccess fileAccess,
				[MarshalAs(UnmanagedType.U4)] System.IO.FileShare fileShare,
				int securityAttributes,
				[MarshalAs(UnmanagedType.U4)] System.IO.FileMode creationDisposition,
				uint flags,
				IntPtr template);

			[DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			[return: MarshalAs(UnmanagedType.Bool)]
			static extern bool OpenProcessToken(IntPtr ProcessHandle,
				UInt32 DesiredAccess, out IntPtr TokenHandle);

			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			static extern IntPtr GetCurrentProcess();

			[DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
			[return: MarshalAs(UnmanagedType.Bool)]
			static extern bool LookupPrivilegeValue(string lpSystemName, string lpName,
				out LUID lpLuid);

			[DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			[return: MarshalAs(UnmanagedType.Bool)]
			static extern bool AdjustTokenPrivileges(IntPtr TokenHandle,
				[MarshalAs(UnmanagedType.Bool)]bool DisableAllPrivileges,
				ref TOKEN_PRIVILEGES NewState,
				Int32 BufferLength,
				//ref TOKEN_PRIVILEGES PreviousState,					!! for some reason this won't accept null
				IntPtr PreviousState,
				IntPtr ReturnLength);

			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			[return: MarshalAs(UnmanagedType.Bool)]
			static extern bool CloseHandle(IntPtr hObject);

			public enum TagType
			{
				None = 0,
				MountPoint = 1,
				SymbolicLink = 2,
				JunctionPoint = 3
			}

			private string normalisedTarget;
			private string actualTarget;
			private TagType tag;

			/// <summary>
			/// Takes a full path to a reparse point and finds the target.
			/// </summary>
			/// <param name="path">Full path of the reparse point</param>
			public ReparsePoint(string path)
			{


				Debug.Assert(!string.IsNullOrEmpty(path) && path.Length > 2 && path[1] == ':' && path[2] == '\\');
				normalisedTarget = "";
				tag = TagType.None;
				bool success;
				int lastError;
				// Apparently we need to have backup privileges
				IntPtr token;
				TOKEN_PRIVILEGES tokenPrivileges = new TOKEN_PRIVILEGES();
				tokenPrivileges.Privileges = new LUID_AND_ATTRIBUTES[1];
				success = OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, out token);
				lastError = Marshal.GetLastWin32Error();
				if (success)
				{
					success = LookupPrivilegeValue(null, SE_BACKUP_NAME, out tokenPrivileges.Privileges[0].Luid);			// null for local system
					lastError = Marshal.GetLastWin32Error();
					if (success)
					{
						tokenPrivileges.PrivilegeCount = 1;
						tokenPrivileges.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
						success = AdjustTokenPrivileges(token, false, ref tokenPrivileges, Marshal.SizeOf(tokenPrivileges), IntPtr.Zero, IntPtr.Zero);
						lastError = Marshal.GetLastWin32Error();
					}
					CloseHandle(token);
				}

				if (success)
				{
					// Open the file and get its handle
					IntPtr handle = CreateFile(path, System.IO.FileAccess.Read, System.IO.FileShare.None, 0, System.IO.FileMode.Open, FILE_FLAG_OPEN_REPARSE_POINT | FILE_FLAG_BACKUP_SEMANTICS, IntPtr.Zero);
					lastError = Marshal.GetLastWin32Error();
					if (handle.ToInt32() >= 0)
					{
						REPARSE_DATA_BUFFER buffer = new REPARSE_DATA_BUFFER();
						// Make up the control code - see CTL_CODE on ntddk.h
						uint controlCode = (FILE_DEVICE_FILE_SYSTEM << 16) | (FILE_ANY_ACCESS << 14) | (FSCTL_GET_REPARSE_POINT << 2) | METHOD_BUFFERED;
						uint bytesReturned;
						success = DeviceIoControl(handle, controlCode, IntPtr.Zero, 0, out buffer, MAXIMUM_REPARSE_DATA_BUFFER_SIZE, out bytesReturned, IntPtr.Zero);
						lastError = Marshal.GetLastWin32Error();
						if (success)
						{
							string subsString = "";
							string printString = "";
							// Note that according to http://wesnerm.blogs.com/net_undocumented/2006/10/symbolic_links_.html
							// Symbolic links store relative paths, while junctions use absolute paths
							// however, they can in fact be either, and may or may not have a leading \.
							Debug.Assert(buffer.ReparseTag == IO_REPARSE_TAG_SYMLINK || buffer.ReparseTag == IO_REPARSE_TAG_MOUNT_POINT,
								"Unrecognised reparse tag");						// We only recognise these two
							if (buffer.ReparseTag == IO_REPARSE_TAG_SYMLINK)
							{
								// for some reason symlinks seem to have an extra two characters on the front
								subsString = new string(buffer.ReparseTarget, (buffer.SubsNameOffset / 2 + 2), buffer.SubsNameLength / 2);
								printString = new string(buffer.ReparseTarget, (buffer.PrintNameOffset / 2 + 2), buffer.PrintNameLength / 2);
								tag = TagType.SymbolicLink;
							}
							else if (buffer.ReparseTag == IO_REPARSE_TAG_MOUNT_POINT)
							{
								// This could be a junction or a mounted drive - a mounted drive starts with "\\??\\Volume"
								subsString = new string(buffer.ReparseTarget, buffer.SubsNameOffset / 2, buffer.SubsNameLength / 2);
								printString = new string(buffer.ReparseTarget, buffer.PrintNameOffset / 2, buffer.PrintNameLength / 2);
								tag = subsString.StartsWith(@"\??\Volume") ? TagType.MountPoint : TagType.JunctionPoint;
							}
							Debug.Assert(!(string.IsNullOrEmpty(subsString) && string.IsNullOrEmpty(printString)), "Failed to retrieve parse point");
							// the printstring should give us what we want
							if (!string.IsNullOrEmpty(printString))
							{
								normalisedTarget = printString;
							}
							else
							{
								// if not we can use the substring with a bit of tweaking
								normalisedTarget = subsString;
								Debug.Assert(normalisedTarget.Length > 2, "Target string too short");
								Debug.Assert(
									(normalisedTarget.StartsWith(@"\??\") && (normalisedTarget[5] == ':' || normalisedTarget.StartsWith(@"\??\Volume")) ||
									(!normalisedTarget.StartsWith(@"\??\") && normalisedTarget[1] != ':')),
									"Malformed subsString");
								// Junction points must be absolute
								Debug.Assert(
										buffer.ReparseTag == IO_REPARSE_TAG_SYMLINK ||
										normalisedTarget.StartsWith(@"\??\Volume") ||
										normalisedTarget[1] == ':',
									"Relative junction point");
								if (normalisedTarget.StartsWith(@"\??\"))
								{
									normalisedTarget = normalisedTarget.Substring(4);
								}
							}
							actualTarget = normalisedTarget;
							// Symlinks can be relative.
							if (buffer.ReparseTag == IO_REPARSE_TAG_SYMLINK && (normalisedTarget.Length < 2 || normalisedTarget[1] != ':'))
							{
								// it's relative, we need to tack it onto the path
								if (normalisedTarget[0] == '\\')
								{
									normalisedTarget = normalisedTarget.Substring(1);
								}
								if (path.EndsWith(@"\"))
								{
									path = path.Substring(0, path.Length - 1);
								}
								// Need to take the symlink name off the path
								normalisedTarget = path.Substring(0, path.LastIndexOf('\\')) + @"\" + normalisedTarget;
								// Note that if the symlink target path contains any ..s these are not normalised but returned as is.
							}
							// Remove any final slash for consistency
							if (normalisedTarget.EndsWith("\\"))
							{
								normalisedTarget = normalisedTarget.Substring(0, normalisedTarget.Length - 1);
							}
						}
						CloseHandle(handle);
					}
					else
					{
						success = false;
					}
				}
			}

			/// <summary>
			/// This returns the normalised target, ie. if the actual target is relative it has been made absolute
			/// Note that it is not fully normalised in that .s and ..s may still be included.
			/// </summary>
			/// <returns>The normalised path</returns>
			public override string ToString()
			{
				return normalisedTarget;
			}

			/// <summary>
			/// Gets the actual target string, before normalising
			/// </summary>
			public string Target
			{
				get
				{
					return actualTarget;
				}
			}

			/// <summary>
			/// Gets the tag
			/// </summary>
			public TagType Tag
			{
				get
				{
					return tag;
				}
			}

			public static bool TypeAvailable()
			{
				return true;
			}
		}

		//This C# code was written by Ingo Karstein for the RoboPowerCopy script

		public class HardLinkHelper
		{
			public struct BY_HANDLE_FILE_INFORMATION
			{
				public uint FileAttributes;
				public FILETIME CreationTime;
				public FILETIME LastAccessTime;
				public FILETIME LastWriteTime;
				public uint VolumeSerialNumber;
				public uint FileSizeHigh;
				public uint FileSizeLow;
				public uint NumberOfLinks;
				public uint FileIndexHigh;
				public uint FileIndexLow;
			}

			[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
			static extern bool GetFileInformationByHandle(SafeFileHandle hFile,
			   out BY_HANDLE_FILE_INFORMATION lpFileInformation);

			static HardLinkHelper()
			{
				AppDomain.CurrentDomain.UnhandledException += new System.UnhandledExceptionEventHandler(CurrentDomain_UnhandledException);
			}

			static void CurrentDomain_UnhandledException(object sender, System.UnhandledExceptionEventArgs e)
			{
				//MessageBox.Show(((Exception)e.ExceptionObject).Message);
			}

			public static BY_HANDLE_FILE_INFORMATION? GetFileInfo(System.IO.FileInfo fi)
			{
				System.IO.FileStream fs = null;

				BY_HANDLE_FILE_INFORMATION ret;
				try
				{
					fs = fi.Open(System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.ReadWrite);
					Microsoft.Win32.SafeHandles.SafeFileHandle sfh = fs.SafeFileHandle;
					if (!sfh.IsClosed && !sfh.IsInvalid)
					{
						GetFileInformationByHandle(sfh, out ret);
						return ret;
					}
					else
					{
						return null;
					}
				}
				catch
				{
					return null;
				}
				finally
				{
					if (fs != null)
					{
						fs.Close();
					};
				}
			}

			public static BY_HANDLE_FILE_INFORMATION? GetFileInfo(LongFileInfo fi)
			{
				System.IO.FileStream fs = null;
				BY_HANDLE_FILE_INFORMATION ret;
				try
				{
					fs = fi.Open(System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.ReadWrite);
					Microsoft.Win32.SafeHandles.SafeFileHandle sfh = fs.SafeFileHandle;
					if (!sfh.IsClosed && !sfh.IsInvalid)
					{
						GetFileInformationByHandle(sfh, out ret);
						return ret;
					}
					else
					{
						return null;
					}
				}
				catch
				{
					return null;
				}
				finally
				{
					if (fs != null)
						fs.Close();
				}
			}

			public static bool TypeAvailable()
			{
				return true;
			}
		}
"@
#endregion


#region CHECK TYPE COMPILATION
	try {
		if( [RoboPowerCopyInfo]::TypeAvailable() -ne $true -or !$?) {
			Write-Error "Fatal Internal Error. Type ""RoboPowerCopyInfo"" not compiled."
			return
		}
	}catch {
		Write-Error "Fatal Internal Error. Type ""RoboPowerCopyInfo"" not compiled."
		return
	}
	
	try {
		if( [ReparsePoint]::TypeAvailable() -ne $true  -or !$? ) {
			Write-Error "Fatal Internal Error. Type ""ReparsePoint"" not compiled."
			return
		}
	}catch {
		Write-Error "Fatal Internal Error. Type ""ReparsePoint"" not compiled."
		return
	}
	
	try {
		if( [HardLinkHelper]::TypeAvailable() -ne $true  -or !$? ) {
			Write-Error "Fatal Internal Error. Type ""HardLinkHelper"" not compiled."
			return
		}
	}catch {
		Write-Error "Fatal Internal Error. Type ""HardLinkHelper"" not compiled."
		return
	}
	
	try {
		if( [LongPathSupport]::TypeAvailable() -ne $true  -or !$? ) {
			Write-Error "Fatal Internal Error. Type ""LongPathSupport"" not compiled."
			return
		}
	}catch {
		Write-Error "Fatal Internal Error. Type ""LongPathSupport"" not compiled."
		return
	}
	
	try {
		if( [LongFileInfo]::TypeAvailable() -ne $true  -or !$? ) {
			Write-Error "Fatal Internal Error. Type ""LongFileInfo"" not compiled."
			return
		}
	}catch {
		Write-Error "Fatal Internal Error. Type ""LongFileInfo"" not compiled."
		return
	}
	
	try {
		if( [LongDirectoryInfo]::TypeAvailable() -ne $true  -or !$? ) {
			Write-Error "Fatal Internal Error. Type ""LongDirectoryInfo"" not compiled."
			return
		}
	}catch {
		Write-Error "Fatal Internal Error. Type ""LongDirectoryInfo"" not compiled."
		return
	}
	
	try {
		if( [CopySecurityHelper]::TypeAvailable() -ne $true  -or !$? ) {
			Write-Error "Fatal Internal Error. Type ""CopySecurityHelper"" not compiled."
			return
		}
	}catch {
		Write-Error "Fatal Internal Error. Type ""CopySecurityHelper"" not compiled."
		return
	}
	
	try {
		if( [AttributeHelper]::TypeAvailable() -ne $true  -or !$? ) {
			Write-Error "Fatal Internal Error. Type ""AttributeHelper"" not compiled."
			return
		}
	}catch {
		Write-Error "Fatal Internal Error. Type ""AttributeHelper"" not compiled."
		return
	}
	
	try {
		if( [FileTimeHelper]::TypeAvailable() -ne $true  -or !$? ) {
			Write-Error "Fatal Internal Error. Type ""FileTimeHelper"" not compiled."
			return
		}
	}catch {
		Write-Error "Fatal Internal Error. Type ""FileTimeHelper"" not compiled."
		return
	}
#endregion

#region PARALLELIZATION SUPPORT - (not implemented yet)
	#This requires to force PowerShell to run under .NET Framework v4.
	
	<# Content "of C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe.config"
	   ...but does not work at the moment
		
		<?xml version="1.0" encoding="utf-8"?>
		<configuration>
		    <startup>
		      <supportedRuntime version="v4.0.30319" />
		    </startup>
		</configuration>
	#>
	if($useParallelProcessing) {
		$mscorlib = ([System.AppDomain]::CurrentDomain.GetAssemblies() | ? {$_.ManifestModule.Name -eq "mscorlib.dll" } | select -First 1)
		if( $mscorlib -eq $null -or $mscorlib.FullName -inotlike "mscorlib*" -or $mscorlib.ImageRuntimeVersion.Major -ne 4 ) {
			#It's not .NET v4 - Parallel Processing not available
			$useParallelProcessing = $false
		} else {
			#Source: http://csharpening.net/?p=441
			#Preparing script for parallelization support...
			set-variable -name "ForEachMethod" -Value ( ([System.Threading.Tasks.Parallel].GetMethods([System.Reflection.BindingFlags]::Public `
					-bor [System.Reflection.BindingFlags]::Static) | Where-Object {    
					$_.Name -eq "ForEach" -and $_.GetParameters().Count -eq 2
				} | Select-Object -First 1).MakeGenericMethod([Object])) -Scope Script
		}
	}
#endregion

#######################################################################################################################

#region function: isFileLocked ($filePath)
	function isFileLocked ($filePath) {
	    if( !([LongPathSupport]::FileExists($filePath)) ) {
			return $false
		}
		
		$stream = $null

	    try
	    {
	        $stream = openStream $filePath  "Open"  "ReadWrite"  "None" 
	    }
	    catch [System.IO.IOException]
	    {
	        return $true
	    }
	    finally
	    {
	        if ($stream -ne $null) {
	            $stream.Close()
				$stream.Dispose()
				$stream = $null
			}
	    }

	    return $false
	}
#endregion

#region function: waitForUnlockedFile([string]$filePath, [int]$retryCount, [int]$waitTime)
	function waitForUnlockedFile([string]$filePath, [int]$retryCount, [int]$waitTime) {
		$i = $retryCount
		while( $i -gt 0 ) {
			if( !(isFileLocked $filePath) ) {
				return $true
			}
			$i--
			Start-Sleep -Milliseconds $waitTime
		}
		return $false
	}
#endregion

#region function: writeHeader($stream, $header, [switch]$close) 
	function writeHeader($stream, $header, [switch]$close) {
		try {
			$pos = $stream.Seek(-1*$headerLength, "END")
			$headerData = $header.ToArray()
			$stream.Write($headerData, 0, $headerData.Length)
			$stream.Flush()
			if( $close ) {
				$stream.Close()
				return $null
			}
			
			return $stream
		} catch {
			Write-Error $_.Exception.Message
			return $stream
		}
	}
#endregion

#region function: setDestFileTime($fileinfo, $time)
	function setDestFileTime($fileinfo, $time) {
		$fileinfo.Refresh()
		$fileinfo.CreationTimeUtc = $time
		$fileinfo.LastWriteTimeUtc = $time
		$fileinfo.LastAccessTimeUtc = $time
	}
#endregion

#######################################################################################################################

function writeVerbose() {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
		[string] $Message
	)
	Process
	{
		if( $verboseMemory -ne $null) {
			$verboseMemory.AppendLine($Message)
			return
		}
		
		if( $verboseOutput -is [bool] ) {
			if( $verboseOutput -eq $true ) {
				Write-Verbose $Message -Verbose:$true
			}
		} else {
			$fs = (Get-Variable -Name "VerboseStream" -ErrorAction SilentlyContinue).Value
			if( $fs -eq $null ) {
				if( $verboseOutputAppend ) {
					$fs = [System.IO.File]::AppendText($verboseOutput)
				} else {
					$fs = [System.IO.File]::CreateText($verboseOutput)
				}
				Set-Variable -Name "VerboseStream" -Value $fs -Scope Global
			}
			$fs.WriteLine($Message)
		}
	}
}

function freeVerboseMemory(){
	if( $verboseMemory -ne $null ) {
		$str = $verboseMemory.ToString()
		Set-Variable -Name "verboseMemory" -Value $null -Scope Global
		writeVerbose $str
	}
}

function checkForExistingDestDirectory($obj) {
	$d = $null
	if( $obj -is [LongFileInfo] -or $obj -is [System.IO.FileInfo] ) {
		$d = $obj.Directory
	} else {
		$d = $obj.Parent
	}
	if( !$d.Exists ) {
		checkForExistingDestDirectory $d
		writeVerbose -Message "Directory created: ""$($diDst.FullName)""" 
		$d.Create()
	}
}

function hashCompare([ref]$buffer1, [ref]$buffer2){
	if( (Get-Variable -Name "hashAlgObj" -Scope Global -ErrorAction SilentlyContinue) -eq $null ) {
		set-variable -Name "hashAlgObj" -Scope Global -Value (invoke-expression -Command  "[$($hashAlg)]::Create()")
	}
	$buffer1Hash  = $hashAlgObj.ComputeHash($buffer1.Value, 0, $readBytes)
	$buffer2Hash = $hashAlgObj.ComputeHash($buffer2.Value, 0, $readBytes)
	$ok = $true
	if($buffer1Hash.Count -eq $buffer2Hash.Count ) {
		for($i = 0; $i -lt $buffer1Hash.Count; $i++) {
			if( $buffer1Hash[$i] -ne $buffer2Hash[$i] ) {
				$ok = $false
				break
			}
		}
	}
	return $ok
}

#region function: convertFileSizeToString($filesize)
	function convertFileSizeToString($filesize){
		$filesizeStr = ""
		if( !$showFileSizeInBytes ) {
			if( $filesize -ge 1099511627776 ) {
				#>= 1 terabyte
				$filesizeStr = ($filesize / 1099511627776).ToString("#.# ""t""", $scriptCulture)
			} elseif( $filesize -ge 1073741824 ) {
				# >= 1 gigabyte
				$filesizeStr = ($filesize / 1073741824).ToString("#.# ""g""", $scriptCulture)
			} elseif( $filesize -ge 1048576 ) {
				# >= 1 megabyte
				$filesizeStr = ($filesize / 1048576).ToString("#.# ""m""", $scriptCulture)
			} else {
				$filesizeStr = $filesize.ToString()
			}
		} else {
			$filesizeStr = $filesize.ToString()
		}
		return $filesizeStr
	}
#endregion

#region function: outputFile($src, $op) 
	function outputFile($src, $op) {
		$filesize = $src.Length
		$filesizeStr = convertFileSizeToString $filesize
		
		$outMsg = "             "
		$outMsg += $op.PadLeft(10, " ").Substring(0,10)
		$outMsg += " "
		$outMsg += $filesizeStr.PadLeft(17, " ").Substring(0,17)
		$outMsg += "        "
		$outMsg += $src.Name
		Write-Host $outMsg
	}
#endregion

#region function: GetFileInfoObject($fileName) 
	function GetFileInfoObject($fileName) {
		if( !$longPathSupport ) {
			return New-Object System.IO.FileInfo($fileName)
		} else {
			return New-Object LongFileInfo($fileName)
		}
	}
#endregion

#region function: GetDirectoryInfoObject($dirName) 
	function GetDirectoryInfoObject($dirName) {
		if( !$longPathSupport ) {
			return New-Object System.IO.DirectoryInfo($dirName)
		} else {
			return New-Object LongDirectoryInfo($dirName)
		}
	}
#endregion

function roboPowerCopy($src, $dst) {
	writeVerbose -Message "FILE: $($src)"
	
	$errorOccured = $false
	
	$fiSrc = GetFileInfoObject -fileName $src
	$fiDst = GetFileInfoObject -fileName $dst
	$doCopy = $false

	if( !$longPathSupport ) {
		if( !$fiSrc.Exists ) {
			Write-Warning "Source file does not exist!"
			return $false
		}
		if( $dst.Length -gt 255 ) {
			Write-Warning "Destination path too long!"
			return $false
		}
	}
	
	$op = "****"

	if( $fiDst.Exists ) {
		writeVerbose -Message "Destination file already exists" 
	    if ($fiDst.LastWriteTimeUtc -gt $fiSrc.LastWriteTimeUtc ) {
			writeVerbose -Message "DO COPY: Destination file is newer then source"  
			$op = "Newer"
		  	$doCopy = $true
		} elseif ($fiDst.LastWriteTimeUtc -lt $fiSrc.LastWriteTimeUtc ) {
			writeVerbose -Message "DO COPY: Destination file is older then source"  
			$op = "Older"
			if( !$excludeOlderFiles ) {
				$global:infoSkippedFileCnt++;
				$global:infoSkippedFileSize += $fiSrc.Length;

				outputFile $fiSrc $op
				return $true
			}
	  		$doCopy = $true
		} elseif( $fiSrc.Length -ne $fiDst.Length ) {
			writeVerbose -Message "DO COPY: File length diffrent"  
			$op = "Diffrent"
		  	$doCopy = $true
		} 
  	} else {
		writeVerbose -Message "DO COPY: Destination file does not exist"  
		if( !$copyData ) {
			$op = "Lonely"
		} else {
			$op = "*New"
	    }
		$doCopy = $true
	}
  
	$infiniteLockRetry = $false
	$header = $null 
	$localRestartableMode = $restartableMode
	
	if( $fiSrc.Length -le $chunkSize ) {
		writeVerbose -Message "Deactivating ""Restartable Mode"" for this file."
		$localRestartableMode = $false
	}

	if( $fiDst.LastWriteTimeUtc -eq $whileCopyTimestamp ) {
		writeVerbose -Message """Copy Timestamp"" found on destination file. May be a further copy operation was canceled."  
		$readStream = $null
	    try {
			writeVerbose -Message "Try to read copy header..."  
			$readStream = $fiDst.Open([io.filemode]::Open, [io.fileaccess]::ReadWrite, [io.fileshare]::ReadWrite)
			$pos = $readStream.Seek(-1*$headerLength, "END")
			$headerData = New-Object "System.Byte[]" $headerLength
			$readBytes = $readStream.Read($headerData, 0, $headerData.Length)
			if( $readBytes -ne $headerLength ) {
				$doCopy = $false
				$errorOccured = $true
				return $false
			}

			writeVerbose -Message "Read header bytes"  
			
			$infiniteLockRetry = $true
			
			$header = New-Object RoboPowerCopyInfo
			$ret = $header.FromArray($headerData)
			if( !([bool]$ret) ) {
				writeVerbose -Message "Header not valid"  
				if( $localRestartableMode ) {
					writeVerbose -Message "Removing existing destination file because the copy header was not found but RoboPowerCopy was started in ""restartable mode""."  
				  	if( $readStream -ne $null ) {
						writeVerbose -Message "STREAM CLOSED"  
				  		$readStream.Close()
						$readStream = $null
						if( !(waitForUnlockedFile -filePath $dst -retryCount 5 -waitTime 1000 )){
							Write-Error "Destination file is locked. Cannot write to it."
							$errorOccured = $true
							return $false
						}
					}
					$header = $null
					$fiDst.Delete()
					$fiDst.Refresh()
					$doCopy = $true
					$op = "*Restart"
				}
			} else {
				$op = $header.CopyOp
			}
		} catch {
		    WriteVerbose -Message "An error occured: $($_.Exception.Message)"
			writeVerbose -Message "Removing existing destination file because the copy header was not found but RoboPowerCopy was started in ""restartable mode""."  
		  	if( $readStream -ne $null ) {
				writeVerbose -Message "STREAM CLOSED"  
		  		$readStream.Close()
				$readStream = $null
				if( !(waitForUnlockedFile -filePath $dst -retryCount 5 -waitTime 1000 )){
					Write-Error "Destination file is locked. Cannot write to it."
					$errorOccured = $true
					return $false
				}
			}
			$fiDst.Delete()
			$fiDst.Refresh()
			$doCopy = $true
			$op = "*Restart"
		} finally {
		  	if( $readStream -ne $null ) {
				writeVerbose -Message "STREAM CLOSED"  
		  		$readStream.Close()
				$readStream = $null
				if( !(waitForUnlockedFile -filePath $dst -retryCount 5 -waitTime 1000 )){
					Write-Error "Destination file is locked. Cannot write to it."
					$errorOccured = $true
					return $false
				}
			}
		}
  	}
	
	if( $header -ne $null -and $localRestartableMode -eq $null ) {
		writeVerbose  -Message "Header found but none was expected. Deleting destination file..."  
		$header = $null
		if( !(waitForUnlockedFile -filePath $dst -retryCount 5 -waitTime 1000 )){
			Write-Error "Destination file is locked. Cannot write to it."
			$errorOccured = $true
			return $false
		}
		$fiDst.Delete()
		$fiDst.Refresh()
		$doCopy = $true
		$op = "*Restart"
	}
	
	$rcbwActive = $checksumBeforeCopy
  
	if( $header -ne $null ) {
		writeVerbose -Message "Checking found header"  
		if( $header.SourceFileLastWriteTimeUtc -ne $fiSrc.LastWriteTimeUtc -or
		    $header.SourceFileLastLength -ne $fiSrc.Length -or
			$header.SourceFileCreationTimeUtc -ne $fiSrc.CreationTimeUtc ) {

			writeVerbose  -Message "Header values diffrent from source files current values. Deleting destination file..."  
			$header = $null
			if( !(waitForUnlockedFile -filePath $dst -retryCount 5 -waitTime 1000 )){
				Write-Error "Destination file is locked. Cannot write to it."
				$errorOccured = $true
				return $false
			}
			$fiDst.Delete()
			$fiDst.Refresh()
			$doCopy = $true
			$op = "*Restart"
		}
	}

  	$copyDone = $false
	
	if( !$doCopy -and $overwrite ) {
		$op = "*Force"
		$doCopy = $true
	}
	
  	$fiDst.Refresh()
  	if( $doCopy -and $copyData ) {
		outputFile $fiSrc $op

		$sw = New-Object System.Diagnostics.Stopwatch
		
		$sw.Start()
		
		writeVerbose -Message "START COPY PROCESS"  
	  	$readStream = $null
		$writeStream = $null
		
		if( $fiDst.Exists ) {
			if( $header -eq $null -and $localRestartableMode -and !$onlyCreateStructure ) {
				$writeStream = $fiDst.Open([IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::Read)
				writeVerbose -Message "  DESTINATION FILE STREAM OPENED"  

				[FileTimeHelper]::SetFileTimesUtc($writeStream.SafeFileHandle, $whileCopyTimestamp, $whileCopyTimestamp, $whileCopyTimestamp)
				writeVerbose -Message "  Copy timestamp set. Now expanding file to it's destination size"  
				
				$header = New-Object RoboPowerCopyInfo
				$header.LastWriteTime = [DateTime]::Now
				$header.copyOp = $op
				$header.SourceFileLastWriteTimeUtc = $fiSrc.LastWriteTimeUtc
				$header.SourceFileLastLength = $fiSrc.Length
				$header.SourceFileCreationTimeUtc = $fiSrc.CreationTimeUtc
				$writeStream = writeHeader $writeStream $header
				writeVerbose -Message "  Header added"  
			} else {
				$writeStream = $fiDst.Open([IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::Read)
				writeVerbose -Message "  DESTINATION FILE STREAM OPENED"  

				[FileTimeHelper]::SetFileTimesUtc($writeStream.SafeFileHandle, $whileCopyTimestamp, $whileCopyTimestamp, $whileCopyTimestamp)
				writeVerbose -Message "  Copy timestamp set. Now expanding file to it's destination size"  
				
				if( !$onlyCreateStructure) {
					$writeStream.SetLength($fiSrc.Length )
					writeVerbose -Message "    Size set"  
				} else {
					$writeStream.SetLength(0)
					writeVerbose -Message "    No size set because ""Create Structure Only"" mode is active."  
				}

				$writeStream.Flush()
			}
		} else {
			$rcbwActive = $false
			checkForExistingDestDirectory $fiDst
			writeVerbose -Message "  Destination file does not exist. Now creating it..."  
			if( !(waitForUnlockedFile -filePath $dst -retryCount 5 -waitTime 1000 )){
				Write-Error "  Destination file is locked. Cannot write to it."
				$errorOccured = $true
				return $false
			}
			$writeStream =$fiDst.Open([IO.FileMode]::Create, [IO.FileAccess]::Write, [IO.FileShare]::None)
			$writeStream.Close()
			writeVerbose -Message "  Destination file created. Setting copy timestamp now..."  
			
			if( !(waitForUnlockedFile -filePath $dst -retryCount 5 -waitTime 1000 )){
				Write-Error "    Destination file is locked. Cannot write to it."
				$errorOccured = $true
				return $false
			}			
			
			$writeStream = $fiDst.Open([IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::Read)
			writeVerbose -Message "  DESTINATION FILE STREAM OPENED"  

			[FileTimeHelper]::SetFileTimesUtc($writeStream.SafeFileHandle, $whileCopyTimestamp, $whileCopyTimestamp, $whileCopyTimestamp)
			writeVerbose -Message "  Copy timestamp set. Now expanding file to it's destination size"  			
			
			if( $localRestartableMode -and !$onlyCreateStructure ) {
				$writeStream.SetLength($fiSrc.Length + $headerLength)
				writeVerbose -Message "  Size set. Now adding header for ""Restartable Mode"""  
				$header = New-Object RoboPowerCopyInfo
				$header.LastWriteTime = [DateTime]::Now
				$header.copyOp = $op
				$header.SourceFileLastWriteTimeUtc = $fiSrc.LastWriteTimeUtc
				$header.SourceFileLastLength = $fiSrc.Length
				$header.SourceFileCreationTimeUtc = $fiSrc.CreationTimeUtc
				$writeStream = writeHeader $writeStream $header
				writeVerbose -Message "  Header added"  
			} else {
				if( !$onlyCreateStructure) {
					$writeStream.SetLength($fiSrc.Length )
					writeVerbose -Message "    Size set"  
				} else {
					writeVerbose -Message "    No size set because ""Create Structure Only"" mode is active."  
				}
				$writeStream.Flush()
			}
		}
		
		$readWritePos = 0
		if( $header -ne $null ) {
			$readWritePos = $header.NextWritePosition
			writeVerbose -Message "  Extracting next read/write position from copy header. It's: $($readWritePos)"  
		}
		
		if( $readStream -eq $null ) {
			$readStream = $fiSrc.Open([IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
			writeVerbose -Message "  SOURCE FILE STREAM OPENED"  
		}
		
		if( $writeStream -eq $null ) {
			$writeStream = $fiDst.Open([IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::Read)
			writeVerbose -Message "  DESTINATION FILE STREAM OPENED"  
		}
		
		if( ($fiSrc.Length -ne 0) -and (!$onlyCreateStructure) ) {
			$copyDone = $false
			try {
				$readBytes = 0
				$buffer = New-Object "System.Byte[]" $chunkSize
				$buffer2 = $null
				
				if( $checksumBeforeCopy ) {
					$buffer2 = New-Object "System.Byte[]" $chunkSize
				}
				
				do {
					try {
						writeVerbose -Message "  Staring next file part copy" 
						$lastReadWritePos = $readWritePos
						
						writeVerbose -Message "    Seeking source file to next read position"  
						$pos = $readStream.Seek($readWritePos, "BEGIN")
						writeVerbose -Message "    Seeking destination file to next write position"  
						$pos = $writeStream.Seek($readWritePos, "BEGIN")
						
						if( $checksumBeforeCopy ) {
							writeVerbose -Message "    Comparing checksum *before* copy"  
						}

						writeVerbose -Message "    Reading binary data... ($($chunkSize) bytes maximum.)"  
						$readBytes = $readStream.Read($buffer, 0, $chunkSize)
						writeVerbose -Message "    Bytes read: $($readBytes)"  
					  	if( $readBytes -gt 0 ) {
							$doWrite = $true
							
							if( $rcbwActive  ) {
								writeVerbose -Message "    Comparing checksum *before* copy"  
								$readBytes2 = $writeStream.Read($buffer2, 0, $readBytes)
								if( $readBytes2 -eq $readBytes ) {
									$ok = hashCompare ([ref]$buffer) ([ref]$buffer2)
									
									if( $ok ) {
										writeVerbose -Message "      Hashes equal. No write action for this file chunck required." 
										$doWrite = $false
									} else {
										writeVerbose -Message "      Hashes not equal. Write action required." 
										$doWrite = $true
									}									
								} 
								
								$pos = $writeStream.Seek($readWritePos, "BEGIN")
							}

							if( $doWrite ) {
								writeVerbose -Message "    Writing binary data..."  
								$writeStream.Write($buffer, 0, $readBytes)
								$writeStream.Flush()
								writeVerbose -Message "    Data written!"  
							}
					
							if($verify ) {
								writeVerbose -Message "    Start verify"  
								$verifyBuf = New-Object "System.Byte[]" $chunkSize
								writeVerbose -Message "      OPEN VERIFY STREAM ON DESTINATION FILE"  
								$verifyStream = openStream $dst ([io.filemode]::Open) ([io.fileaccess]::Read) ([io.fileshare]::ReadWrite)
								try {
									writeVerbose -Message "      Seeking destination file to last write position"  
									$pos = $verifyStream.Seek($lastReadWritePos, "BEGIN")
									writeVerbose -Message "      Reading same amount of bytes as last written"  
									$readVerifyBytes = $verifyStream.Read($verifyBuf, 0, $readBytes)
									if( $readVerifyBytes -ne $readBytes ) {
										writeVerbose -Message "      Less bytes read from verify stream than last written"  
										Write-Error "Verify failed"
									} else {
										writeVerbose -Message "      Creating SHA256 hashes..."  
										$ok = hashCompare ([ref]$buffer) ([ref]$verifyBuf)
										
										if( !$ok ) {
											Write-Error "  Hashes not equal!"
										} else {
											writeVerbose -Message "      Hashes are equal!"  
										}
									}
								} catch {
									Write-Error $_.Exception.Message
									$errorOccured = $true
									return $false
								}
								finally {
									if( $verifyStream -ne $null ) {
										$verifyStream.Close()
										writeVerbose -Message "    CLOSE VERIFY STREAM ON DESTINATION FILE"  
									}
								}
							}
						
							$readWritePos += $readBytes
							if( $percentProgress ) {
								Write-Progress -Status "Copy" -Activity "File Copy" -PercentComplete ($readStream.Position / $readStream.Length * 100.0)
								#Write-Host ("{0:0}%  " -f ($readStream.Position / $readStream.Length * 100.0) ) -NoNewline
							}
						}

						if( $localRestartableMode ) {
							writeVerbose -Message "    Updating copy header after write operation"  
							$header.LastWriteTime = [DateTime]::Now
							$header.NextWritePosition = $readWritePos
							$writeStream = writeHeader $writeStream $header
						}					
					} catch {
						Write-Error $_.Exception.Message
						$errorOccured = $true
						return $false
					} finally {
						writeVerbose -Message "  Finished file part copy"  
					}
				} while($readBytes -ne 0)
				
				if( $percentProgress ) {
					Write-Progress -Status "Copy" -Activity "File Copy" -PercentComplete 100 -Completed 
				}

				if($readBytes -eq 0 ) {
					if( $localRestartableMode ) {
						writeVerbose -Message "  Remove copy header"  
						$writeStream.SetLength($fiSrc.Length )
					} 
					$writeStream.Flush()
					$writeStream.Close()
					$writeStream = $null
					
					$copyDone = $true
				}
			} finally {
			  	if( $writeStream -ne $null ) {
					writeVerbose  -Message "  STREAM CLOSING ON DESTINATION FILE"
					$writeStream.Close()
				}
				
				if( !$copyDone ) { 
					writeVerbose  -Message "  Set time stamps of destination file to the source files time stamps"
					if( !(waitForUnlockedFile -filePath $fiDst.FullName -retryCount 5 -waitTime 1000 )){
						Write-Error "  Destination file is locked. Cannot write to it."
							$errorOccured = $true
							return $false
					}						

					[FileTimeHelper]::SetFileTimesUtc($fiDst.FullName, $whileCopyTimestamp, $whileCopyTimestamp, $whileCopyTimestamp)
				}
					
				if( $readStream -ne $null ) {
					writeVerbose  -Message "  STREAM CLOSING ON SOURCE FILE"
			  		$readStream.close()
				}
			}
		} else {
			#if( $fiSrc.Length -ne 0 ) ... ELSE
			if( $writeStream -ne $null ) {
				writeVerbose  -Message "  STREAM CLOSING ON SOURCE FILE"
				$writeStream.Close()
			}
			$copyDone = $true
		}
		
		if( $copyDone -and $doCopy ) {
			if( !(waitForUnlockedFile -filePath $fiDst.FullName -retryCount 5 -waitTime 1000 )){
				Write-Error "  Destination file is locked. Cannot write to it."
				return $false
			}
		}
			
		$fiDst.Refresh()
		if( $copyDone -and $doCopy -and $copyTimestamps ) {
			writeVerbose -Message "  Set file time"  

			writeVerbose -Message "  Copy file timestamps from source to destination file." 
			$fiSrc.Refresh()
			$fiDst.CreationTimeUtc = $fiSrc.CreationTimeUtc
			$fiDst.LastWriteTimeUtc = $fiSrc.LastWriteTimeUtc
			$fiDst.LastAccessTimeUtc = $fiSrc.LastAccessTimeUtc
			$fiDst.Refresh()
			if( $fiDst.CreationTimeUtc -ne $fiSrc.CreationTimeUtc ) {
				$errorOccured = $true
				writeVerbose -message "    Could not set ""CreationTime"" of destination file correctly."
				return $false
			}
			if( $fiDst.LastWriteTimeUtc -ne $fiSrc.LastWriteTimeUtc ) {
				$errorOccured = $true
				writeVerbose -message "    Could not set ""LastWriteTimeUtc"" of destination file correctly."
				return $false
			}
			if( $fiDst.LastAccessTimeUtc -ne $fiSrc.LastAccessTimeUtc ) {
				$errorOccured = $true
				writeVerbose -message "    Could not set ""LastAccessTimeUtc"" of destination file correctly."
				return $false
			}
		}
		
		if( $copyDone -and $doCopy -and ($copySecurity -or $copyOwner -or $copyAuditInfo) ) {
			writeVerbose -Message "  Copy file security from source to destination file." 
			$result = [CopySecurityHelper]::CopySecurity($fiSrc.Fullname, $fiDst.Fullname, $copySecurity, $copyAuditInfo, $copyOwner)
			if( !$result ) {
				writeVerbose -Message "    Copying security failed!" 
				$errorOccured = $true
				return $false
			}
		}		
		
		if( $copyDone -and $doCopy -and $copyAttributes ) {
			writeVerbose -Message "  Copy file attributes from source to destination file." 
			$attr = $fiSrc.get_Attributes()
			if( $attr -eq -1 ) {
				writeVerbose -Message "    Reading attributes of source file failed!" 
				$errorOccured = $true
				return $false
			}
			writeVerbose -message "   Source attribs are $($attr.ToString())"
			$fiDst.set_Attributes($attr)
			$result = ($fiDst.Attributes -eq $attr)
			if( !$result ) {
				$errorOccured = $true
				writeVerbose -Message "    Could not set attributes!"
				return $false
			}
		} else {
			writeVerbose -Message "Don't copy file attributes from source to destination file but setting ""Archive"" attribute." 
			$fiDst.set_Attributes([System.IO.FileAttributes]::Archive)
		}
		
		if($copyDone -and $doCopy -and $removeArchiveAttribOnSource)
		{
			writeVerbose -Message "  Remove ""Archive"" attribute on source file." 
			$a = -bnot [System.IO.FileAttributes]::Archive
			$attr = $fiSrc.get_attributes() -band $a
			if( $attr -eq -1 ) {
				writeVerbose -Message "    Reading attributes of source file failed!" 
				$errorOccured = $true
				return $false
			}
			$fiSrc.set_Attributes($attr)
			$result = ($fiSrc.Attributes -eq $attr)
			if( !$result ) {
				$errorOccured = $true
				writeVerbose -Message "    Could not set attributes!"
				return $false
			}
		}
		
		if( $copyDone -and $doCopy -and ([int]$attribsAddOnDest) -gt -1 ) {
			writeVerbose -Message "  Add file attribs on destination file." 
			$attr = $fiDst.get_attributes()
			if( $attr -eq -1 ) {
				writeVerbose -Message "    Reading attributes of destination file failed!" 
				$errorOccured = $true
				return $false
			}
			$attr = ([System.IO.FileAttributes]$attr -bor $attribsAddOnDest)
			$fiDst.set_Attributes($attr)
			$fiDst.Refresh()
			$result = ($fiDst.Attributes -eq ([System.IO.FileAttributes]($fiSrc.Attributes -bor $attribsAddOnDest)))
			if( !$result ) {
				$errorOccured = $true
				writeVerbose -Message "    Could not set attributes!"
				return $false
			}
		}

		if( $copyDone -and $doCopy -and ([int]$attribsRemoveOnDest) -gt -1 ) {
			writeVerbose -Message "  Remove file attribs on destination file." 
			$attr = $fiDst.get_attributes()
			if( $attr -eq -1 ) {
				writeVerbose -Message "    Reading attributes of destination file failed!" 
				$errorOccured = $true
				return $false
			}
			$attr = ([System.IO.FileAttributes]$attr -band (-bnot $attribsRemoveOnDest))
			$fiDst.set_Attributes($attr)
			$result = ($fiDst.Attributes -eq ([System.IO.FileAttributes]$fiSrc.Attributes -band (-bnot $attribsRemoveOnDest)))
			if( !$result ) {
				$errorOccured = $true
				writeVerbose -Message "    Could not set attributes!"
				return $false
			}
		}
		
		$global:infoCopiedFileCnt++;
		$global:infoCopiedFileSize += $fiSrc.Length;
		
		$sw.Stop()
		
		writeVerbose -Message "FINISHED COPY PROCESS ($($sw.ElapsedMilliseconds) ms)"  
  	} else {
		#if( $doCopy ) ... ELSE
		outputFile $fiSrc "Equal"

		$global:infoSkippedFileCnt++;
		$global:infoSkippedFileSize += $file.Length;

		$fiDst.Refresh()
		if( $fixtime ) {
			writeVerbose -Message "  Fix file time"  

			writeVerbose -Message "  Copy file timestamps from source to destination file." 
			$fiSrc.Refresh()
			$fiDst.CreationTimeUtc = $fiSrc.CreationTimeUtc
			$fiDst.LastWriteTimeUtc = $fiSrc.LastWriteTimeUtc
			$fiDst.LastAccessTimeUtc = $fiSrc.LastAccessTimeUtc
			$fiDst.Refresh()
			if( $fiDst.CreationTimeUtc -ne $fiSrc.CreationTimeUtc ) {
				$errorOccured = $true
				writeVerbose -message "    Could not set ""CreationTime"" of destination file correctly."
				return $false
			}
			if( $fiDst.LastWriteTimeUtc -ne $fiSrc.LastWriteTimeUtc ) {
				$errorOccured = $true
				writeVerbose -message "    Could not set ""LastWriteTimeUtc"" of destination file correctly."
				return $false
			}
			if( $fiDst.LastAccessTimeUtc -ne $fiSrc.LastAccessTimeUtc ) {
				$errorOccured = $true
				writeVerbose -message "    Could not set ""LastAccessTimeUtc"" of destination file correctly."
				return $false
			}
		}
		
		if( ($copySecurity -or $copyOwner -or $copyAuditInfo) -and $fixsec ) {
			writeVerbose -Message "  Fix file security from source to destination file." 
			$result = [CopySecurityHelper]::CopySecurity($fiSrc, $fiDst, $copySecurity, $copyAuditInfo, $copyOwner)
			if( $result -eq $null -or $result.ResultCode -ne 0 ) {
				writeVerbose -Message "    Copying security failed!" 
				$errorOccured = $true
				return $false
			}
		}		
		
	}
		
	return $true
}

#######################################################################################################################

#region function: checkForExcludedFile($file)
	function checkForExcludedFile($file) {
		foreach($i in $excludeFile) {
			if( $file -ilike $i ) {
				return $true
			}
		}
		return $false
	}
#endregion

#region function: checkForExcludedDirectory($dir)
	function checkForExcludedDirectory($dir) {
		foreach($i in $excludeDir) {
			if( $dir -ilike $i ) {
				return $true
			}
		}
		return $false
	}
#endregion

#region function: checkForJunctionPointExclude($dir)
	function checkForJunctionPointExclude($dir) {
		if( !$excludeSymbolicLinks -and !$excludeLinkedFiles -and !$excludeLinkedDirectories ) {
			return $false
		}
		
		if( ($dir -is [LongFileInfo] -or $dir -is [System.IO.FileInfo]) -and ($excludeLinkedFiles -or $excludeSymbolicLinks) ) {
			$info = [HardLinkHelper]::GetFileInfo($dir)
			if( $info.NumberOfLinks -gt 1 ) {
				writeVerbose  -Message "File ""$($dir.FullName)"" is a hard link and has multiple ($($info.NumberOfLinks)) file names."
				return $true
			}
		}
		
		if( ($dir -is [LongDirectoryInfo] -or $dir -is [System.IO.DirectoryInfo]) -and ($excludeLinkedDirectories -or $excludeSymbolicLinks) ) {
			$reparsePoint = new-object ReparsePoint($dir.FullName)
			$x  = $reparsePoint.Tag
			if( $x -ne 0 ) {
				switch([int]$x) {
					1 { writeVerbose  -Message "Directory ""$($dir.FullName)"" is Mount Point"
						break }
					2 { writeVerbose  -Message "Directory ""$($dir.FullName)"" is Symbolic Link"
						break }
					3 { writeVerbose  -Message "Directory ""$($dir.FullName)"" is Junction Point"
				  		break }
				}
				
				return $true 
			}
		}
		
		return $false
	}
#endregion

#region function: checkForMinAge($file)
	function checkForMinAge($file) {
		if( $minage -lt 0 ) {
			return $false
		}
		
		if( $minage -lt 1900 ) {
			$d = [DateTime]::UtcNow.AddDays(-1*$minage)
			return ($file.LastWriteTimeUtc -ge $d)
		} else {
			$year = [int]($minage / 10000)
			$month = [int](($minage % 10000) / 100)
			$day = [int]($minage % 100)
			$d = New-Object System.DateTime($year, $month, $day, 0, 0, 0, [DateTimeKind]::Utc)
			return ($file.LastWriteTimeUtc -ge $d)
		}
	}
#endregion

#region function: checkForMaxAge($file)
	function checkForMaxAge($file) {
		if( $maxage -lt 0 ) {
			return $false
		}
		
		if( $maxage -lt 1900 ) {
			$d = [DateTime]::UtcNow.AddDays(-1*$maxage)
			return ($file.LastWriteTimeUtc -le $d)
		} else {
			$year = [int]($maxage / 10000)
			$month = [int](($maxage % 10000) / 100)
			$day = [int]($maxage % 100)
			$d = New-Object System.DateTime($year, $month, $day, 0, 0, 0, [DateTimeKind]::Utc)
			return ($file.LastWriteTimeUtc -le $d)
		}
	}
#endregion

#region function: checkForMinLastAccessDate($file)
	function checkForMinLastAccessDate($file) {
		if( $minLastAccessDate -lt 0 ) {
			return $false
		}
		
		if( $minLastAccessDate -lt 1900 ) {
			$d = [DateTime]::NowUtcNow.AddDays(-1*$minage)
			return ($file.LastAccessTimeUtc -ge $d)
		} else {
			$year = [int]($minLastAccessDate / 10000)
			$month = [int](($minLastAccessDate % 10000) / 100)
			$day = [int]($minLastAccessDate % 100)
			$d = New-Object System.DateTime($year, $month, $day, 0, 0, 0, [DateTimeKind]::Utc)
			return ($file.LastAccessTimeUtc -ge $d)
		}
	}
#endregion

#region function: checkForMaxLastAccessDate($file) 
	function checkForMaxLastAccessDate($file) {
		if( $maxLastAccessDate -lt 0 ) {
			return $false
		}
		
		if( $maxLastAccessDate -lt 1900 ) {
			$d = [DateTime]::NowUtcNow.AddDays(-1*$maxage)
			return ($file.LastAccessTimeUtc -le $d)
		} else {
			$year = [int]($maxLastAccessDate / 10000)
			$month = [int](($maxLastAccessDate % 10000) / 100)
			$day = [int]($maxLastAccessDate % 100)
			$d = New-Object System.DateTime($year, $month, $day, 0, 0, 0, [DateTimeKind]::Utc)
			return ($file.LastAccessTimeUtc -le $d)
		}
	}
#endregion

#region function: checkForLonelyFile($src, $dst)
	function checkForLonelyFile($src, $dst) {
		if( !$excludeLonelyFiles ) {
			return $false
		}
		
		if( !([System.IO.File]::Exists($dst)) ) {
			return $true
		}
	}
#endregion

#region function: checkForExtraFile($src, $dst)
	function checkForExtraFile($src, $dst) {
		if( !$excludeLonelyFiles ) {
			return $false
		}
		
		throw "Not implemented"
	#NOT IMPLEMENTED
	#
	#	if( !([System.IO.File]::Exists($dst)) ) {
	#		return $true
	#	}

		return $false
	}
#endregion

#region function: checkForMinFileSize($src)
	function checkForMinFileSize($src) {
		if( $minSize -lt 0 ) {
			return $false
		}
		
		if( (New-Object LongFileInfo($src)).Length -ge $minSize  ) {
			return $true
		}
	}
#endregion

#region function: checkForMaxFileSize($src)
	function checkForMaxFileSize($src) {
		if( $maxSize -lt 0 ) {
			return $false
		}
		
		if( (New-Object LongFileInfo($src)).Length -le $maxSize  ) {
			return $true
		}
	}
#endregion


#######################################################################################################################

#region
	function getFileList($diDst, $filesToCopy) {
		if( $filesToCopy -eq $null ) {
			return $diDst.GetFiles()
		} elseif( $filesToCopy -eq "*.*" ) {
			return $diDst.GetFiles()
		} elseif( $filesToCopy.Length -eq 1 ) {
			return $diDst.GetFiles($filesToCopy[0])
		} else {
			$ret = @()
			foreach($i in $filesToCopy) {
				$ret += @($diDst.GetFiles($i))
			}
			return $ret
		}
	}
#endregion

#region function: cleanupDestDirFiles($diDst, $diSrc)
	function cleanupDestDirFiles($diDst, $diSrc) {
		$fileList = getFileList $diDst $filesToCopy
		if( $fileList  -eq $null -or $fileList.Length -eq 0 ) {
			return
		}
		foreach($file in $fileList) {
			$name = $file.Name
			$srcName = ""
			$srcObj = $null
			if( $longPathSupport ) {
				$srcName = [LongPathSupport]::Combine( $diSrc.fullQualifiedName, $name )
				$srcObj = New-Object LongFileInfo ($srcName)
			} else 
			{
				$srcName = [System.IO.Path]::Combine( $diSrc.fullname, $name )
				$srcObj = New-Object System.IO.FileInfo($srcName)
			}
			if( $srcObj.Exists ) {
				#It's OK!
			} else {
				writeVerbose -Message "  Extra file found on destination" 
				outputFile -src $file -op "*Extra"
				if( $purge ) {
					$retryCnt = $maxRetryCount
					do{
						try {
							$result = $file.Delete()
							$global:infoDeletedFileCnt++
							$global:infoDeletedFileSize += $file.Length
							break
						} catch {
							Write-Host "ERROR: $($_.Exception.Message)"
							Start-Sleep -Milliseconds $waitBeforeRetry
						}
						$retryCnt--
					} while( $retryCnt -gt 0 ) 
					if( $longPathSupport ) {
						if( [LongPathSupport]::FileExists($srcName) ) {
							Write-Warning "  Cannot delete extra file on destination" 
						}
					} else 
					{
						if( [System.IO.File]::Exists($srcName) ) {
							Write-Warning "  Cannot delete extra file on destination" 
						}
					}
				}
			}
		}
	}
#endregion

#region function: checkForExistingDestFileOfExcludedSourceFile($file, $diDst)
	function checkForExistingDestFileOfExcludedSourceFile($file, $diDst) {
		$name = $file.Name
		$dstName = ""
		$dstObj = $null
		if( $longPathSupport ) {
			$dstName = [LongPathSupport]::Combine( $diDst.fullQualifiedName, $name )
			$dstObj = New-Object LongFileInfo ($dstName)
		} else 
		{
			$dstName = [System.IO.Path]::Combine( $diDst.fullname, $name )
			$dstObj = New-Object System.IO.FileInfo($dstName)
		}
		if( !$dstObj.Exists ) {
			#It's OK!
		} else {
			writeVerbose -Message "  Extra file found on destination" 
			outputFile -src $file -op "*Extra"
			if( $purge ) {
				$retryCnt = $maxRetryCount
				do{
					try {
						$result = $dstObj.Delete()
						$global:infoDeletedFileCnt++
						$global:infoDeletedFileSize += $file.Length
						break
					} catch {
						Write-Host "ERROR: $($_.Exception.Message)"
						Start-Sleep -Milliseconds $waitBeforeRetry
					}
					$retryCnt--
				} while( $retryCnt -gt 0 ) 
				if( $longPathSupport ) {
					if( [LongPathSupport]::FileExists($dstName) ) {
						Write-Warning "  Cannot delete extra file on destination" 
					}
				} else 
				{
					if( [System.IO.File]::Exists($dstName) ) {
						Write-Warning "  Cannot delete extra file on destination" 
					}
				}
			}
		}
	}
#endregion

#region function: checkForExistingDestDirOfExcludedSourceDir($dir, $diDst)
	function checkForExistingDestDirOfExcludedSourceDir($dir, $diDst) {
		$name = $dir.Name
		$dstName = ""
		$dstObj = $null
		if( $longPathSupport ) {
			$dstName = [LongPathSupport]::Combine( $diDst.fullQualifiedName, $name )
			$dstObj = New-Object LongDirectoryInfo($dstName)
		} else 
		{
			$dstName = [System.IO.Path]::Combine( $diDst.fullname, $name )
			$dstObj = New-Object System.IO.DirectoryInfo($dstName)
		}
		if( !$dstObj.Exists ) {
			#It's OK!
		} else {
			writeVerbose -Message "  Extra directory found on destination" 
			outputFile -src $file -op "*Extra"
			if( $purge ) {
				$retryCnt = $maxRetryCount
				do{
					try {
						$result = $dstObj.Delete($true)
						$global:infoDeletedDirCnt++
						break
					} catch {
						Write-Host "ERROR: $($_.Exception.Message)"
						Start-Sleep -Milliseconds $waitBeforeRetry
					}
					$retryCnt--
				} while( $retryCnt -gt 0 ) 
				if( $longPathSupport ) {
					if( [LongPathSupport]::DirectoryExists($dstName) ) {
						Write-Warning "  Cannot delete extra directory on destination" 
					}
				} else 
				{
					if( [System.IO.Directory]::Exists($dstName) ) {
						Write-Warning "  Cannot delete extra directory on destination" 
					}
				}
			}
		}
	}
#endregion

#region function: cleanupDestDirSubdirectories($diDst, $diSrc)
	function cleanupDestDirSubdirectories($diDst, $diSrc) {		
		$dirList = $diDst.GetDirectories()
		if( $dirList  -eq $null -or $dirList.Length -eq 0 ) {
			return
		}
		foreach($dir in $dirList) {
			$name = $dir.Name
			$srcName = ""
			$srcObj = $null
			if( $longPathSupport ) {
				$srcName = [LongPathSupport]::Combine( $diSrc.fullQualifiedName, $name )
				$srcObj = New-Object LongDirectoryInfo($srcName)
			} else 
			{
				$srcName = [System.IO.Path]::Combine( $diSrc.fullname, $name )
				$srcObj = New-Object System.IO.DirectoryInfo($srcName)
			}
			if( $srcObj.exists ) {
				#It's OK!
			} else {
				outputDir -op "*Extra" -src $srcObj -subFilesCount -1
				writeVerbose -Message "  Extra directory found on destination" 
				if( $purge ) {
					$retryCnt = $maxRetryCount
					do{
						try {
							$result = $dir.Delete($true)
							$global:infoDeletedDirCnt++
							break
						} catch {
							Write-Host "ERROR: $($_.Exception.Message)"
							Start-Sleep -Milliseconds $waitBeforeRetry
						}
						$retryCnt--
					} while( $retryCnt -gt 0 ) 
					if( $longPathSupport ) {
						if( [LongPathSupport]::DirectoryExists($srcName) ) {
							Write-Warning "  Cannot delete extra directory on destination" 
						}
					} else 
					{
						if( [System.IO.Directory]::Exists($srcName) ) {
							Write-Warning "  Cannot delete extra directory on destination" 
						}
					}
				}
			}			
		}
	}
#endregion

#region function: outputDir($src, $subFilesCount, [switch]$skipped, $op="") 
	function outputDir($src, $subFilesCount, [switch]$skipped, $op="") {
		$fileCnt = $subFilesCount
		if( $skipped ) {
			$fileCnt = -1
		}
		$outMsg = "           "
		$outMsg += $op.PadLeft(10," ").Substring(0,10)
		$outMsg += $fileCnt.ToString().PadLeft(8, " ").Substring(0,8)
		$outMsg += "    " + $src.FullName
		Write-Host $outMsg
	}
#endregion

function scan-dir($src, $dst, $lvl = 1) {
	if( $lvl -gt $maxCopyLevel -and $maxCopyLevel -gt 0 ) {
		writeVerbose -Message "Exclude directory because max copy level reached" 
		return
	}
	
  	$diSrc = GetDirectoryInfoObject $src
  	$diDst = GetDirectoryInfoObject $dst
  
    $subDirs = $diSrc.GetDirectories()
  	$subFiles = getFileList $diSrc $filesToCopy 

	outputDir $diSrc ($subFiles.Count + $subDirs.Count)

	if( !$longPathSupport ) {
	  	if( !$diSrc.Exists ) {
			writeVerbose "Source directory does not exist!"
			return 
		}
		if( $dst.Length -gt 255 ) {
			writeVerbose "Destination path too long!"
			return
		}
  	}
    
  	if( $excludeEmptySubfolders ) {
  		if( $subDirs.Count -eq 0 -and $subFiles.Count -eq 0 ) {
			return
		}
  	}
  
  	if( $diDst.Exists -ne $true -and !$excludeEmptySubfolders ){
    	$result = $diDst.Create()
		if( $result -ne $true ) {
			WriteVerbose -Message "Failed to create directory."
			return
		}
  	}
  
  	if( $subFiles.Length -gt 0 ) {
	  	foreach($file in $subFiles){
			$dstFile = $null
			if( $longPathSupport ) {
		    	$dstFile = [LongPathSupport]::Combine($diDst.FullQualifiedName, $file.Name)
			} else {
				$dstFile = [System.IO.Path]::Combine($diDst.FullName, $file.Name)

			  	if( !$file.Exists ) {
					Write-Warning "Source file does not exist! May be path too long."
					return
				}
				if( $dstFile.Length -gt 255 ) {
					Write-Warning "Destination path too long!"
					return
				}
		  	}

		  	$excludeReasonFile = (checkForExcludedFile $file.FullName)
			$excludeReasonLink = (checkForJunctionPointExclude $file)
			$excludeReasonMinAge = (checkForMinAge $file)
			$excludeReasonMaxAge = (checkForMinAge $file)
			$excludeReasonLonely = (checkForLonelyFile $file $dst)
			$excludeReasonExtra = (checkForExtraFile $file $dst)
			$excludeReasonMinSize = (checkForMinFileSize $file)
			$excludeReasonMaxSize = (checkForMaxFileSize $file)
			$excludeReasonMinLastAccessDate = (checkForMinLastAccessDate $file)
			$excludeReasonMaxLastAccessDate = (checkForMaxLastAccessDate $file)
			$excludeReasonOnlyArchive = ($onlyIfArchive -and (($file.Attributes -band [System.IO.FileAttributes]::Archive) -eq 0))
			
		  	if( !$excludeReasonFile -and !$excludeReasonLink -and !$excludeReasonMinAge -and !$excludeReasonMaxAge -and
			    !$excludeReasonLonely -and !$excludeReasonExtra -and !$excludeReasonMinSize -and !$excludeReasonMaxSize -and
				!$excludeReasonMinLastAccessDate -and !$excludeReasonMaxLastAccessDate -and !$excludeReasonOnlyArchive) {
				$retryCnt = $maxRetryCount
				$result = $true
				do {
					$result = (roboPowerCopy $file.FullName  $dstFile)
					if( $result -ne $true ) {
						Write-Host "ERROR"
						if( $retryCnt -gt 0 ){ 
							Write-Host "Wait $($waitBeforeRetry) seconds"
							start-sleep -Seconds $waitBeforeRetry
						}
					} else {
						$global:infoCopiedDirCnt++
					}
				} until( $retryCnt -le 0 -or $result -eq $true )
				
				if( $result -eq $false ) {
					$global:infoErrorFileCnt++;
					$global:infoErrorFileSize += $file.Length;
				}
				
			} else {
				writeVerbose "Excluding file: ""$($file.FullName)""" 
				$op = "*Extra"
				if( $excludeReasonFile ) {writeVerbose -Message "  Excluding because of file name pattern match"; $op = "Name" }
				if( $excludeReasonLink ) {writeVerbose -Message "  Excluding because of hard link " }
				if( $excludeReasonMinAge ) {writeVerbose -Message "  Excluding because of min age" }
				if( $excludeReasonMaxAge ) {writeVerbose -Message "  Excluding because of max age" }
				if( $excludeReasonLonely ) {writeVerbose -Message "  Excluding because its a lonely file" }
				if( $excludeReasonExtra ) {writeVerbose -Message "  Excluding because its a extra file" }
				if( $excludeReasonMinSize ) {writeVerbose -Message "  Excluding because of min size" }
				if( $excludeReasonMaxSize ) {writeVerbose -Message "  Excluding because of max size" }
				if( $excludeReasonMinLastAccessDate ) {writeVerbose -Message "  Excluding because of min Last Access Date" }
				if( $excludeReasonMaxLastAccessDate ) {writeVerbose -Message "  Excluding because of max Last Access Date" }
				if( $excludeReasonMaxAge ) {writeVerbose -Message "  Excluding because of max age" }
				if( $excludeReasonOnlyArchive ) {writeVerbose -Message "  Exclude because archive file not set" }
				
				outputFile -src $file -op $op
				checkForExistingDestFileOfExcludedSourceFile $file $dst
				
				$global:infoSkippedFileCnt++;
				$global:infoSkippedFileSize += $file.Length;
			}
	  	}
	}
	
	cleanupDestDirFiles $diDst $diSrc
    
	if( $recursive ) {
		if($subDirs.Length -gt 0 ) {
		  	foreach($dir in $subDirs){
				$dstDir =  $null
				if( $longPathSupport ) {
			    	$dstDir = [LongPathSupport]::Combine($diDst.FullQualifiedName, $dir.Name)
				}else{
			    	$dstDir = [System.IO.Path]::Combine($diDst.FullName, $dir.Name)

				  	if( !$dir.Exists ) {
						Write-Warning "Source directory does not exist! May be path too long."
						return
					}
					if( $dstDir.Length -gt 255 ) {
						Write-Warning "Destination path too long!"
						return
					}
			  	}

		  		$excludeReasonDir = (checkForExcludedDirectory $dir.FullName)
				$excludeReasonLink = (checkForJunctionPointExclude $dir)
				
				if( !$excludeReasonDir -and !$excludeReasonLink) {
					scan-dir $dir.FullName $dstDir ($lvl + 1)
				} else {
					$global:infoSkippedDirCnt++
					writeVerbose "Excluding dir: ""$($dir.FullName)""" 
					$op = "*Extra"
					if( $excludeReasonDir ) {writeVerbose -Message "  Excluding because of directory name pattern match"; $op = "Name" }
					if( $excludeReasonLink ) {writeVerbose -Message "  Excluding because of hard link "; $op = "Link" }
					outputDir -src $dir -op $op -skipped
					checkForExistingDestFileOfExcludedSourceFile $dir $dst
				}
		  	}
		}
	}
	
	cleanupDestDirSubdirectories $diDst $diSrc
	
	#check wheter directory is empty now
    $subDirs = $diSrc.GetDirectories()
  	$subFiles = getFileList $diSrc $filesToCopy 

  	if( $excludeEmptySubfolders ) {
		if( $subDirs.Length -eq 0 -and $subFiles.Length -eq 0 ) {
			if($purge) {
				$global:infoDeletedDirCnt++
				$dir.Delete($true)
			}
		}
	}
	
	if( $copyDirectoryTimestamps ){
		writeVerbose -Message "  Set directory time"  

		writeVerbose -Message "  Copy directory timestamps from source to destination file." 
		$diSrc.Refresh()
		$diDst.CreationTimeUtc = $diSrc.CreationTimeUtc
		$diDst.LastWriteTimeUtc = $diSrc.LastWriteTimeUtc
		$diDst.LastAccessTimeUtc = $diSrc.LastAccessTimeUtc
		$diDst.Refresh()
		if( $diDst.CreationTimeUtc -ne $diSrc.CreationTimeUtc ) {
			$errorOccured = $true
			writeVerbose -message "    Could not set ""CreationTime"" of destination directory correctly."
			return $false
		}
		if( $diDst.LastWriteTimeUtc -ne $diSrc.LastWriteTimeUtc ) {
			$errorOccured = $true
			writeVerbose -message "    Could not set ""LastWriteTimeUtc"" of destination directory correctly."
			return $false
		}
		if( $diDst.LastAccessTimeUtc -ne $diSrc.LastAccessTimeUtc ) {
			$errorOccured = $true
			writeVerbose -message "    Could not set ""LastAccessTimeUtc"" of destination directory correctly."
			return $false
		}
	}

#  	if( $excludeEmptySubfolders ) {
#	  	$subDirsDst = [LongPathSupport]::FindFilesAndDirs($dst, "Directories", $false)
#	  	$subFilesDst = [LongPathSupport]::FindFilesAndDirs($dst, "Files", $false)
#  		if( $subDirs.Count -eq 0 -and $subFiles.Count -eq 0 ) {
#			writeVerbose -Message "Deleting directory ""$($diDst.FullName)"" after processing it's child items because the directory is empty now." 
#			$diDst.Delete()
#		}
#  	}
}

#region function: openStream($fileName, $mode, $access, $share)
	function openStream($fileName, $mode, $access, $share){
		if( $longPathSupport ) {
			return [LongPathSupport]::Open($fileName, $access, $mode, $share)
		} else {
			return [System.IO.File]::Open($fileName, $mode, $access, $share)
		}
	}
#endregion

#region function: processAttribMask($mask)
	function processAttribMask($mask) {
		#this is the mask of RoboCopy: RASHCNET
		$ret = 0
		foreach($c in $mask.ToUpper().ToCharArray()) {
			switch( $c ) {
			  "R" { 
					$ret = $ret -bor [System.IO.FileAttributes]::ReadOnly
			  		break
			  }
			  "A" { 
					$ret = $ret -bor [System.IO.FileAttributes]::Archive
			  		break
			  }
			  "S" { 
					$ret = $ret -bor [System.IO.FileAttributes]::System
			  		break
			  }
			  "H" { 
					$ret = $ret -bor [System.IO.FileAttributes]::Hidden
			  		break
			  }
			  "C" { 
					$ret = $ret -bor [System.IO.FileAttributes]::Compressed
			  		break
			  }
			  "N" { 
					$ret = $ret -bor [System.IO.FileAttributes]::Normal
			  		break
			  }
			  "E" { 
					$ret = $ret -bor [System.IO.FileAttributes]::Encrypted
			  		break
			  }
			  "T" { 
					$ret = $ret -bor [System.IO.FileAttributes]::Temporary
			  		break
			  }
			  default {
			  		Write-Error "Attribute ""$($c)"" unknown."
			  		throw "Attribute ""$($c)"" unknown."
					return -1
			  }
			}
		}
		
		return ([System.IO.FileAttributes]$ret)
	}
#endregion

#region function: writeStartMsg() 
	function writeStartMsg{
			Write-Host @"
-------------------------------------------------------------------------------
   RoboPowerCopy     ::     Robust PowerShell based File Copy

	   A PowerShell 2.0 based clone of Microsoft's famous "RoboCopy" tool.
	   Written by Ingo Karstein, 2011.
	   
	   Visit http://robopowercopy.codeplex.com for the latest version.
	   
	   Version: $($roboPowerCopyVersion.ToString()) / $($roboPowerCopyVersionDate.ToShortDateString())
-------------------------------------------------------------------------------

  Started : $($startDateTimeStr)
"@
	}
#endregion

#region function: writeUsage([switch]$isInvalidParam, $paramName, $paramPos)
	function writeUsage([switch]$isInvalidParam, $paramName, [int]$paramPos=-1, $message = $null) {
		
		if( $isInvalidParam ) {
			$paramPosInsert = ""
			if($paramPos -gt 0) { $paramPosInsert=("#" + $paramPos + " : ") }
			Write-Host @"
-------------------------------------------------------------------------------

ERROR : Invalid Parameter $($paramPosInsert)"$($paramName)"
$(if( $message -ne $null ) { ($message+"`n") })
       Simple Usage :: ROBOPOWERCOPY.ps1 source destination /MIR

             source :: Source Directory (drive:\path or \\server\share\path).
        destination :: Destination Dir  (drive:\path or \\server\share\path).
               /MIR :: Mirror a complete directory tree.

    For more usage information run ROBOPOWERCOPY.ps1 /?


****  /MIR can DELETE files as well as copy them !
"@
		} else {
			Write-Host @"

       Simple Usage :: ROBOCOPY source destination /MIR

             source :: Source Directory (drive:\path or \\server\share\path).
        destination :: Destination Dir  (drive:\path or \\server\share\path).
               /MIR :: Mirror a complete directory tree.

    For more usage information run ROBOCOPY /?


****  /MIR can DELETE files as well as copy them !
"@
		}
	}
#endregion

#region function: writeParameter($src, $dst)
	function writeParameter($src, $dst) {
		Write-Output @"

     Source : $($src)
Destination : $($dst)

      Files : $([string]::join("`r`n              ", $filesToCopy))
              
      Excluded Files : $([string]::join("`r`n                       ", $excludeFile))

Excluded Directories : $([string]::join("`r`n                       ", $excludeDir))
                       
  Options: $([string]::join(" ",$paramListForOutput))

------------------------------------------------------------------------------		

"@		
	}
#endregion  

#region function: processParam( $param, $options )
	$global:paramListForOutput = @()
	function processParam( $param, $options ){
		if( $param -eq $null -and $options -eq $null) {
			return $true
		}
		
		if( $param -eq $null -and $options -ne $null ) {
			if( $options.Length -gt 0 ) {
				Set-Variable -Name "srcDir" -Value ($options[0]) -Scope Global
			} else {
				Set-Variable -Name "srcDir" -Value ([String]::Empty) -Scope Global
			}
			
			if( $options.Length -gt 1 ) {
				Set-Variable -Name "dstDir" -Value ($options[1]) -Scope Global
			} else {
				Set-Variable -Name "dstDir" -Value ([String]::Empty) -Scope Global
			}
			
			if( $options.Length -gt 2 ) {
				Set-Variable -Name "filesToCopy" -Value (New-Object System.Collections.ArrayList(@(,$options))) -Scope Global
				$filesToCopy.RemoveRange(0,2)
			} else {
				Set-Variable -Name "filesToCopy" -Value ("*.*") -Scope Global
			}
			return $true
		}
		
		$paramUpper = $param.ToUpper()
		if( $paramUpper -ne "/XD" -and $paramUpper -ne "/XF" ) {
			if( $options -ne $null -and $options -is [array] -and $options.length -eq 1 ) {
				$global:paramListForOutput += @("$($param):""$($options)""")	
			} elseif( $options -ne $null -and $options -is [array] -and $options.length -gt 1 ) {
				$x = [string]::join('" "',$options)
				$global:paramListForOutput += @("$($param) ""$($x)""")	
			} else {
				$global:paramListForOutput += @("$($param)")	
			}
		}
		
		try {
			switch( $param.ToUpper() ) {
				"/R" {
					writeVerbose -Message "Parsing parameter ""/R"" with options ""$($options)""" 
					if( $options -eq $null -or $options.Count -ne 1 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "maxRetryCount" -Value ([int]$options[0]) -Scope Global
					return $true
				}
				"/W" {
					writeVerbose -Message "Parsing parameter ""/W"" with options ""$($options)""" 
					if( $options -eq $null -or $options.Count -ne 1 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "waitBeforeRetry" -Value ([int]$options[0]) -Scope Global
					return $true
				}
				"/MAX" {
					writeVerbose -Message "Parsing parameter ""/MAX"" with options ""$($options)""" 
					if( $options -eq $null -or $options.Count -ne 1 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "maxsize" -Value ([int]$options[0]) -Scope Global
					return $true
				}
				"/MIN" {
					writeVerbose -Message "Parsing parameter ""/MIN"" with options ""$($options)""" 
					if( $options -eq $null -or $options.Count -ne 1 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "minsize" -Value ([int]$options[0]) -Scope Global
					return $true
				}
				"/MINAGE" {
					writeVerbose -Message "Parsing parameter ""/MINAGE"" with options ""$($options)""" 
					if( $options -eq $null -or $options.Count -ne 1 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "minage" -Value ([int]$options[0]) -Scope Global
					return $true
				}
				"/MAXAGE" {
					writeVerbose -Message "Parsing parameter ""/MAXAGE"" with options ""$($options)""" 
					if( $options -eq $null -or $options.Count -ne 1 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "maxage" -Value ([int]$options[0]) -Scope Global
					return $true
				}
				"/MINLAD" {
					writeVerbose -Message "Parsing parameter ""/MINLAD"" with options ""$($options)""" 
					if( $options -eq $null -or $options.Count -ne 1 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "minlad" -Value ([int]$options[0]) -Scope Global
					return $true
				}
				"/MAXLAD" {
					writeVerbose -Message "Parsing parameter ""/MAXLAD"" with options ""$($options)""" 
					if( $options -eq $null -or $options.Count -ne 1 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "maxlad" -Value ([int]$options[0]) -Scope Global
					return $true
				}
				"/XD" {
					writeVerbose -Message "Parsing parameter ""/XD"" with options ""$($options)""" 
					if( $options -eq $null ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "excludeDir" -Value ($excludeDir + @($options)) -Scope Global
					return $true
				}
				"/XF" {
					writeVerbose -Message "Parsing parameter ""/XF"" with options ""$($options)""" 
					if( $options -eq $null ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "excludeFile" -Value ($excludeFile + @($options)) -Scope Global
					return $true
				}
				"/XJ" {
					writeVerbose -Message "Parsing parameter ""/XJ""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "excludeSymbolicLinks" -Value $true -Scope Global
					return $true
				}
				"/V" {
					writeVerbose -Message "Parsing parameter ""/V""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "detailedOutput" -Value $true -Scope Global
					return $true
				}
				"/VV+" {
					writeVerbose -Message "Parsing parameter ""/V+""" 
					if( ($options -ne $null) -and ($options.Count -ne 1 ) ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "verboseOutput" -Value ([string]($options[0])) -Scope Global
					Set-Variable -Name "verboseOutputAppend" -Value ($true) -Scope Global
					freeVerboseMemory
					return $true
				} 
				"/VV" {
					writeVerbose -Message "Parsing parameter ""/V""" 
					if( ($options -ne $null) -and ($options.Count -lt 0 -or $options.Count -gt 1) ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					if( ($options -eq $null) -or $options.Count -eq 0 ) {
						Set-Variable -Name "verboseOutput" -Value ($true) -Scope Global
					} else {
						Set-Variable -Name "verboseOutput" -Value ([string]($options[0])) -Scope Global
					}
					Set-Variable -Name "verboseOutputAppend" -Value ($false) -Scope Global
					freeVerboseMemory
					return $true
				}
				"/CHUNK" {
					writeVerbose -Message "Parsing parameter ""/CHUNK"" with options ""$($options)""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "chunkSize" -Value ([int]$options[0]) -Scope Global
					return $true
				}
				"/Z" {
					writeVerbose -Message "Parsing parameter ""/Z""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "restartableMode" -Value $true -Scope Global
					return $true
				}
				"/BYTES" {
					writeVerbose -Message "Parsing parameter ""/BYTES""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "showFileSizeInBytes" -Value $true -Scope Global
					return $true
				}
				"/A" {
					writeVerbose -Message "Parsing parameter ""/A""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "onlyIfArchive" -Value $true -Scope Global
					return $true
				}
				"/M" {
					writeVerbose -Message "Parsing parameter ""/M""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "removeArchiveAttribOnSource" -Value $true -Scope Global
					return $true
				}
				"/CREATE" {
					writeVerbose -Message "Parsing parameter ""/CREATE""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "onlyCreateStructure" -Value $true -Scope Global
					return $true
				}
				"/S" {
					writeVerbose -Message "Parsing parameter ""/S""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "recursive" -Value $true -Scope Global
					Set-Variable -Name "excludeEmptySubfolders" -Value $true -Scope Global
					return $true
				}
				"/E" {
					writeVerbose -Message "Parsing parameter ""/E""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "recursive" -Value $true -Scope Global
					Set-Variable -Name "excludeEmptySubfolders" -Value $false -Scope Global
					return $true
				}
				"/LEV" {
					writeVerbose -Message "Parsing parameter ""/LEV"" with options ""$($options)""" 
					if( $options -eq $null -or $options.Count -ne 1 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "maxCopyLevel" -Value ([int]$options[0]) -Scope Global
					return $true
				}
				"/A+" {
					writeVerbose -Message "Parsing parameter ""/A+"" with options ""$($options)""" 
					if( $options -eq $null -or $options.Count -ne 1 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					$mask = $options[0]
					
					Set-Variable -Name "attribsAddOnDest" -Value (processAttribMask $mask) -Scope Global
					return $true
				}
				"/256" {
					writeVerbose -Message "Parsing parameter ""/256""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "longPathSupport" -Value $false -Scope Global
					return $true
				}
				"/A-" {
					writeVerbose -Message "Parsing parameter ""/A-"" with options ""$($options)""" 
					if( $options -eq $null -or $options.Count -ne 1 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					$mask = $options[0]
					
					Set-Variable -Name "attribsRemoveOnDest" -Value (processAttribMask $mask) -Scope Global
					return $true
				}	
				"/RCBW" { #"Read and check before write"
					writeVerbose -Message "Parsing parameter ""/RCBW""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "checksumBeforeCopy" -Value $true -Scope Global
					return $true
				}		
				"/VERIFY" { #"Read and check before write"
					writeVerbose -Message "Parsing parameter ""/VERIFY""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "verify" -Value $true -Scope Global
					return $true
				}
				"/NP" { 
					writeVerbose -Message "Parsing parameter ""/NP""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "percentProgress" -Value $true -Scope Global
					return $true
				}
				"/IS" { 
					writeVerbose -Message "Parsing parameter ""/IS""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "overwrite" -Value $true -Scope Global
					return $true
				}
				"/SECFIX" {
					writeVerbose -Message "Parsing parameter ""/SECFIX""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "fixsec" -Value $true -Scope Global
					return $true
				}
				"/TIMFIX" {
					writeVerbose -Message "Parsing parameter ""/TIMFIX""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "fixtime" -Value $true -Scope Global
					return $true
				}				
				"/PURGE" {
					writeVerbose -Message "Parsing parameter ""/PURGE""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "purge" -Value $true -Scope Global
					return $true				
				}
				"/MIR" {
					writeVerbose -Message "Parsing parameter ""/MIR""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					Set-Variable -Name "recursive" -Value $true -Scope Global
					Set-Variable -Name "excludeEmptySubfolders" -Value $false -Scope Global
					Set-Variable -Name "purge" -Value $true -Scope Global
					return $true
				}
				"/COPYALL" { 
					writeVerbose -Message "Parsing parameter ""/COPYALL""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
						
					Set-Variable -Name "copyData" -Value $true -Scope Global
					Set-Variable -Name "copyAttributes" -Value $true -Scope Global
					Set-Variable -Name "copyTimestamps" -Value $true -Scope Global
					Set-Variable -Name "copySecurity" -Value $true -Scope Global
					Set-Variable -Name "copyOwner" -Value $true -Scope Global
					Set-Variable -Name "copyAuditInfo" -Value $true -Scope Global
			  		return $true
				}	
				"/SEC" { 
					writeVerbose -Message "Parsing parameter ""/SEC""" 
					if( $options -ne $null -and $options.Count -ne 0 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
						
					Set-Variable -Name "copyData" -Value $true -Scope Global
					Set-Variable -Name "copyAttributes" -Value $true -Scope Global
					Set-Variable -Name "copyTimestamps" -Value $true -Scope Global
					Set-Variable -Name "copySecurity" -Value $true -Scope Global
			  		return $true
				}					
				"/COPY" {
					writeVerbose -Message "Parsing parameter ""/COPY"" with options ""$($options)""" 
					if( $options -eq $null -or $options.Count -ne 1 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					#options: DATSOU

					foreach($c in ($options[0]).ToUpper().ToCharArray()) {
						switch( $c ) {
						  "D" { 
								Set-Variable -Name "copyData" -Value $true -Scope Global
						  		break
						  }
						  "A" { 
								Set-Variable -Name "copyAttributes" -Value $true -Scope Global
						  		break
						  }
						  "T" { 
								Set-Variable -Name "copyTimestamps" -Value $true -Scope Global
						  		break
						  }
						  "S" { 
								Set-Variable -Name "copySecurity" -Value $true -Scope Global
						  		break
						  }
						  "O" { 
								Set-Variable -Name "copyOwner" -Value $true -Scope Global
						  		break
						  }
						  "U" { 
								Set-Variable -Name "copyAuditInfo" -Value $true -Scope Global
						  		break
						  }
						  default {
						  		Write-Error "Attribute ""$($c)"" unknown."
						  		throw "Attribute ""$($c)"" unknown."
								return $false
						  }
						}
					}
					return $true
				}
				"/DCOPY" {
					writeVerbose -Message "Parsing parameter ""/DCOPY"" with options ""$($options)""" 
					if( $options -eq $null -or $options.Count -ne 1 ) {
						Write-Error "Parameter ""$($param)"" does not have the correct number of values"
						return $false
					}
					#options: DATSOU

					foreach($c in ($options[0]).ToUpper().ToCharArray()) {
						switch( $c ) {
						  "T" { 
								Set-Variable -Name "copyDirectoryTimestamps" -Value $true -Scope Global
						  		break
						  }
						  default {
						  		Write-Error "Attribute ""$($c)"" unknown."
						  		throw "Attribute ""$($c)"" unknown."
								return $false
						  }
						}
					}
					return $true
				}
			}
		} catch {
			Write-Error "Error while parsing parameter ""$($param)""."
		}
		return $false
	}
#endregion

#region MAIN
	$stopwatch = New-Object System.Diagnostics.Stopwatch

	try {
		writeStartMsg

		#region Command line processing
			if( $args.Length -gt 0 ) {
				$invalidParam = $false
				$i = 0
				$lastParam = $null
				$lastParamOptions=@()
				$paramCount = 0

				while( $i -lt $args.Count ) {
					$a = $args[$i]

					if($a.startswith("/")) {
						if( !(processParam $lastParam $lastParamOptions) ) {
							$invalidParam = $true
							break
						}
						
						$lastParam = $null
						$lastParamOptions = $null
						$paramCount++;
						
						$idx = $a.IndexOfAny(('"',':'))
						if( $a[$idx] -eq ":" ) {
							$c = $a.Split(':', 2)
							$a = $c[0]
							$b = $c[1]
							$lastParam = $a
							$lastParamOptions += @($b.Trim(@('"')))
						}elseif( $a[$idx] -eq '"' ) {
							$c = $a.Split('"', 2)
							$a = $c[0]
							$b = $c[1]
							$lastParam = $a
							$lastParamOptions += @($b.Trim(@('"')))
						}else {
							$lastParam = $a
						}
					} else {
						$lastParamOptions += @($a.Trim(@('"')))
					}
					$i += 1
				}

				if( !(processParam $lastParam $lastParamOptions) -and $invalidParam -eq $false ) {
					$invalidParam = $true
				}

				if( $invalidParam ) {
					writeUsage -isInvalidParam -paramName $lastParam -paramPos $paramCount
					
					return
				}
				
				$verboseMemory = $null
				
				writeParameter $srcDir $dstDir
			} else {
				writeUsage
				return
			}
		#endregion
		
		if( $fixsec ) {
			if( !$global:copySecurity -and !$global:copyAuditInfo -and !$global:copyOwner ) {
				writeusage -isInvalidParam -paramName "/SECFIX" -paramPos -1 -message "No security info specified for copy"
				return
			}
		}
		
		if( [string]::IsNullOrEmpty($srcDir) -or [string]::IsNullOrEmpty($dstDir) ) {
			writeUsage
			return
		}
	
		$stopwatch = New-Object System.Diagnostics.Stopwatch
		$stopwatch.start()
		scan-dir $srcDir $dstDir
	} finally {
		$stopwatch.stop()
		$t = $stopwatch.ElapsedTicks
		$ts = New-Object System.TimeSpan($t)

		if( $infoCopiedFileCnt -gt 0 -or $infoSkippedFileCnt -gt 0 -or $infoErrorFileSize -gt 0 ) {
			Write-Host ""
			Write-Host "-------------------------------------------------------------------------------"
			Write-Host ""
			Write-Host  "         Total time:   $($ts.ToString())"
			Write-Host ""
			Write-Host  "  Directories total:   $($infoSkippedDirCnt+$infoCopiedDirCnt)"
			Write-Host  "        Files total:   $($infoCopiedFileCnt+$infoSkippedFileCnt+$infoErrorFileCnt)"
			Write-Host  "         Data total:   $(convertFileSizeToString ($infoCopiedFileSize+$infoSkippedFileSize+$infoErrorFileSize))"
			Write-Host ""
			Write-Host  "       Files copied:   $($infoCopiedFileCnt)"
			Write-Host  " Directories copied:   $($infoCopiedDirCnt)"
			Write-Host  "        Data copied:   $(convertFileSizeToString $infoCopiedFileSize)"
			Write-Host ""
			Write-Host  "      Files skipped:   $($infoSkippedFileCnt)"
			Write-Host  "Directories skipped:   $($infoSkippedDirCnt)"
			Write-Host  "       Data skipped:   $(convertFileSizeToString $infoSkippedFileSize)"
			Write-Host ""
			Write-Host  "   Files with error:   $($infoErrorFileCnt)"
			Write-Host  "    Data with error:   $(convertFileSizeToString $infoErrorFileSize)"
		}
		Write-Host ""
		Write-Host "-------------------------------------------------------------------------------"
		Write-Host ""
		Write-Host " Thanks for using RoboPowerCopy!"
		Write-Host ""

		cleanupVariables
	}
	
#endregion
