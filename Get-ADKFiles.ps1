#Requires -Version 3.0            
            
Function Get-ADKFiles {            
[CmdletBinding()]                
param(            
    [parameter(Mandatory)]                        
    [system.string]$TargetFolder = $null                       
)            
Begin {            
    # Make sure we run as admin                                    
    $usercontext = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()                                    
    $IsAdmin = $usercontext.IsInRole(544)                                                                               
    if (-not($IsAdmin)) {                                    
        Write-Warning "Must run powerShell as Administrator to perform these actions"                                    
        break                        
    }                                     
    $HT = @{}            
    $HT += @{ ErrorAction = 'Stop'}            
    # Validate target folder            
    try {            
        Get-Item $TargetFolder @HT | Out-Null            
    } catch {            
        Write-Warning -Message "The target folder specified as parameter does not exist"            
        break            
    }            
}            
            
Process {            
    $adkGenericURL = (Invoke-WebRequest -Uri http://go.microsoft.com/fwlink/?LinkID=252915 -MaximumRedirection 0 -ErrorAction SilentlyContinue)            
    # There's an expected error saying:            
    # The maximum redirection count has been exceeded.             
    # To increase the number of redirections allowed, supply a higher value to the -MaximumRedirection parameter.            
            
    # 302 = redirect as moved temporarily            
    if ($adkGenericURL.StatusCode -eq 302) {            
                
        # Currently set to http://download.microsoft.com/download/9/9/F/99F5E440-5EB5-4952-9935-B99662C3DF70/adk/            
        $MainURL = $adkGenericURL.Headers.Location            
            
        $AllURLs = DATA {                        
            ConvertFrom-StringData @'
        0=adksetup.exe
        1=035c64a427383070735ec20952cb2f4b.cab
        2=036c618de505eeb40cca35afad6264f5.cab
        3=0765ac62eb011b854b5a09f807cf3ae1.cab
        4=0a3a39d2f8a258e1dea4e76da0ec31b8.cab
        5=0b63b7c537782729483bff2d64a620fa.cab
        6=0c48c56ca00155f992c30167beb8f23d.cab
        7=0ce2876e9da7f82aac8755701aecfa64.cab
        8=0d981f062236baed075df3f42b1747db.cab
        9=0e46101fbce444baccdd11de8eeb0912.cab
        10=11bdc4a4637c4d7ab86107fd13dcb9c6.cab
        11=13d6f0cdd9f32c850d1f4c4509494184.cab
        12=1439dbcbd472f531c37a149237b300fc.cab
        13=158211324176e5cb114e21c6716d44a5.cab
        14=1620efa4ffe2a6563530bd0158b17fe6.cab
        15=17c9d60f2bc5bc54c58782d614afcbf0.cab
        16=18d24450bddd70c148f86bcfceacf59d.cab
        17=18da5aa8b15cb7ace8598742eb63ce18.cab
        18=18e5e442fc73caa309725c0a69394a46.cab
        19=23ca402f61cda3f672b3081da79dab63.cab
        20=24b9e5f1f97c2f05aa95ee1f671fd3cc.cab
        21=2517aec0259281507bfb693d7d136f30.cab
        22=268b1a41f6bd2906449944b964bf7393.cab
        23=28ee6e1d002e82e00e15dc241e27a3d7.cab
        24=2f7e63a939046379735382c19c0f2247.cab
        25=3585b51691616d290315769bec85eb6f.cab
        26=3611bd81544efa3deb061718f15aee0c.cab
        27=36e3c2de16bbebad20daec133c22acb1.cab
        28=377a2b6b26ea305c924c25cf942400d6.cab
        29=3814eaa1d4e897c02ac4ca93e7e7796a.cab
        30=38d93b8047d5efb04cf01ab7ec66d090.cab
        31=39837d43d71c401e7edc9ba3e569cd69.cab
        32=3b71855dfae6a44ab353293c119908b8.cab
        33=3d610ba2a5a333717eea5f9db277718c.cab
        34=3dc1ed76e5648b575ed559e37a1052f0.cab
        35=3e8ac538609776347ea14be446d458a4.cab
        36=413a073d16688e177d7536cd2a64eb43.cab
        37=450f8c76ee138b1d53befd91b735652b.cab
        38=4d15138ec839ce36f5b68c16b332920a.cab
        39=4d2878f43060bacefdd6379f2dae89b0.cab
        40=4e56c6c11e546d4265da4e9ff7686b67.cab
        41=4fc82a5cedaab58e43b487c17f6ef6f3.cab
        42=500e0afd7cc09e1e1d6daca01bc67430.cab
        43=527b957c06e68ebb115b41004f8e3ad0.cab
        44=56dd07dea070851064af5d29cadfac56.cab
        45=56e5d88e2c299be31ce4fc4a604cede4.cab
        46=57007192b3b38fcd019eb88b021e21cc.cab
        47=5775a15b7f297f3e705a74609cb21bbc.cab
        48=5ac1863798809c64e85c2535a27a3da6.cab
        49=5d984200acbde182fd99cbfbe9bad133.cab
        50=625aa8d1c0d2b6e8cf41c50b53868ecd.cab
        51=630e2d20d5f2abcc3403b1d7783db037.cab
        52=662ea66cc7061f8b841891eae8e3a67c.cab
        53=6894c1e1e549c4ab533078e3ff2e92af.cab
        54=690b8ac88bc08254d351654d56805aea.cab
        55=69f8595b00cf4081c2ecc89420610cbd.cab
        56=6bdcd388323175da70d836a25654aa92.cab
        57=6d2cfb2c5343c33c8d9e54e7d1f613f9.cab
        58=6d3c63e785ac9ac618ae3f1416062098.cab
        59=6dc62760f8235e462db8f91f6eaa1d90.cab
        60=7011bf2f8f7f2df2fdd2ed7c82053d7f.cab
        61=7410e4c16d4e8319de73d79027b1d4c8.cab
        62=77adc85e5c49bbd36a91bb751dc55b39.cab
        63=781e7c95c1b6b277057c9b53b7b5a044.cab
        64=795573623ce59474b561fc40f38986eb.cab
        65=7ab29d7f105f1e7814198f23b60f8e5d.cab
        66=7c11b295fb7f25c6d684b1957e96a226.cab
        67=7c195d91008a0a6ad16e535ac228467d.cab
        68=83bd1072721871ea0bdc4fab780d9382.cab
        69=8624feeaa6661d6216b5f27da0e30f65.cab
        70=86ae476dfe0498a5b5d1b6f3076412c7.cab
        71=870d7f92116bc55f7f72e7a9f5d5d6e1.cab
        72=8a7f515d1665d4120c1be4b4f9d78b92.cab
        73=8c27542f7954c25af62730fbb1e211d2.cab
        74=9050f238beb90c3f2db4a387654fec4b.cab
        75=93ed81ef8cf2e77c6ebc8aba5d95b9cf.cab
        76=94cae441bc5628e21814208a973bbb9d.cab
        77=9722214af0ab8aa9dffb6cfdafd937b7.cab
        78=a011a13d3157dae2dbdaa7090daa6acb.cab
        79=a03686381bcfa98a14e9c579f7784def.cab
        80=a1d26d38d4197f7873a8da3a26fc351c.cab
        81=a30d7a714f70ca6aa1a76302010d7914.cab
        82=a32918368eba6a062aaaaf73e3618131.cab
        83=a40aea453ac3e9dd8951c2b125a5fd6f.cab
        84=a4d2213cc44fd2ac2de44c6ad98e88ce.cab
        85=a565f18707816c0d052281154b768ac0.cab
        86=a7eb3390a15bcd2c80a978c75f2dcc4f.cab
        87=aa25d18a5fcce134b0b89fb003ec99ff.cab
        88=aa4db181ead2227e76a3d291da71a672.cab
        89=ab3291752bc7a02f158066789e9b0c03.cab
        90=abadc0ace44c6ba5cad01e2d1408a45f.cab
        91=abbeaf25720d61b6b6339ada72bdd038.cab
        92=ac9ff098e23012b74624db792b538132.cab
        93=Application Compatibility Toolkit-x64_en-us.msi
        94=Application Compatibility Toolkit-x86_en-us.msi
        95=Assessments on Client-x86_en-us.msi
        96=Assessments on Server-x86_en-us.msi
        97=b0189bdfbad208b3ac765f88f21a89df.cab
        98=b3892d561b571a5b8c81d33fbe2d6d24.cab
        99=b5227bb68c3d4641d71b769e3ac606a1.cab
        100=b6758178d78e2a03e1d692660ec642bd.cab
        101=bbf55224a0290f00676ddc410f004498.cab
        102=bc1fef9daa903321722c08ce3cf51261.cab
        103=bd748d6fbff59b2a58cebdb99c3c6747.cab
        104=be7ebc1ac434ead4ab1cf36e3921b70e.cab
        105=c0f42c479da796da513cc5592f0759d3.cab
        106=c6babfeb2e1e6f814e70cacb52a0f923.cab
        107=c98a0a5b63e591b7568b5f66d64dc335.cab
        108=ccf0b1fb9a1f20998b153c44684575a9.cab
        109=cd23bfdfd9e3dfa8475bf59c2c5d6901.cab
        110=cfb8342932e6752026b63046a8d93845.cab
        111=d2611745022d67cf9a7703eb131ca487.cab
        112=d3a3cb9f097a2b86cba7143489e77275.cab
        113=d562ae79e25b943d03fc6aa7a65f9b81.cab
        114=d5ab5e5d3b38824af1c714c289999949.cab
        115=d5abe4833b23e13dc7038bde9c525069.cab
        116=dotNetFx40_Full_x86_x64.exe
        117=e5f4f4dc519b35948be4500a7dfeab14.cab
        118=e65f08c56c86f4e6d7e9358fa99c4c97.cab
        119=ea9c0c38594fd7df374ddfc620f4a1fd.cab
        120=eacac0698d5fa03569c86b25f90113b5.cab
        121=ed711e0a0102f1716cc073671804eb4c.cab
        122=eebe1a56de59fd5a57e26205ff825f33.cab
        123=f17080a8c785c47fe4714b7ad2c797e2.cab
        124=f18258d399eda9b42c75b358b9e9fc62.cab
        125=f2a850bce4500b85f37a8aaa71cbb674.cab
        126=f480ed0b7d2f1676b4c1d5fc82dd7420.cab
        127=f678c5f13eb8d66bba79685df79a5fa7.cab
        128=f7699e5a82dcf6476e5ed2d8a3507ace.cab
        129=fa7c072a4c8f9cf0f901146213ebbce7.cab
        130=fbcf182748fd71a49becc8bb8d87ba92.cab
        131=fcc051e0d61320c78cac9fe4ad56a2a2.cab
        132=fd5778f772c39c09c3dd8cd99e7f0543.cab
        133=fe43ba83b8d1e88cc4f4bfeac0850c6c.cab
        134=Kits Configuration Installer-x86_en-us.msi
        135=Microsoft Compatibility Monitor-x86_en-us.msi
        136=SQLEXPR_x86_ENU.exe
        137=Toolkit Documentation-x86_en-us.msi
        138=User State Migration Tool-x86_en-us.msi
        139=Volume Activation Management Tool-x86_en-us.msi
        140=wasinstaller.exe
        141=WimMountAdkSetupAmd64.exe
        142=WimMountAdkSetupX86.exe
        143=Windows Assessment Services - Client (AMD64 Architecture Specific, Client SKU)-x86_en-us.msi
        144=Windows Assessment Services - Client (AMD64 Architecture Specific, Server SKU)-x86_en-us.msi
        145=Windows Assessment Services - Client (Client SKU)-x86_en-us.msi
        146=Windows Assessment Services - Client (Server SKU)-x86_en-us.msi
        147=Windows Assessment Services - Client (X86 Architecture Specific, Client SKU)-x86_en-us.msi
        148=Windows Assessment Services-x86_en-us.msi
        149=Windows Assessment Toolkit (AMD64 Architecture Specific)-x86_en-us.msi
        150=Windows Assessment Toolkit (X86 Architecture Specific)-x86_en-us.msi
        151=Windows Assessment Toolkit-x86_en-us.msi
        152=Windows Deployment Customizations-x86_en-us.msi
        153=Windows Deployment Tools-x86_en-us.msi
        154=Windows PE x86 x64 wims-x86_en-us.msi
        155=Windows PE x86 x64-x86_en-us.msi
        156=Windows System Image Manager on amd64-x86_en-us.msi
        157=Windows System Image Manager on x86-x86_en-us.msi
        158=WPT Redistributables-x86_en-us.msi
        159=WPTarm-arm_en-us.msi
        160=WPTx64-x86_en-us.msi
        161=WPTx86-x86_en-us.msi
'@            
        }            
            
        # Create target folders if required as BIT doesn't accept missing folders            
        If (-not(Test-Path (Join-Path -Path $TargetFolder -ChildPath Installers))) {            
            try {            
                New-Item -Path (Join-Path -Path $TargetFolder -ChildPath Installers) -ItemType Directory -Force @HT            
                # New-Item -Path $TargetFolder -ItemType Directory -Force -ErrorAction Stop            
            } catch {            
                Write-Warning -Message "Failed to create folder $($TargetFolder)/Installers"            
                break            
            }            
        }            
            
        # Create an job that will downlad our first file            
        $job = Start-BitsTransfer -Suspended -Source "$($MainURL)/$($AllURLs['0'])" -Asynchronous -Destination (Join-Path -Path $TargetFolder -ChildPath ($AllURLs['0']))             
                    
        For ($i = 1 ; $i -lt $AllURLs.Count ; $i++) {            
            $URL = $Destination = $null            
            $URL = "$($MainURL)Installers/$($AllURLs[$i.ToString()])"            
            $Destination = Join-Path -Path (Join-Path -Path $TargetFolder -ChildPath Installers) -ChildPath (([URI]$URL).Segments[-1] -replace '%20'," ")            
            # Add-BitsFile http://technet.microsoft.com/en-us/library/dd819411.aspx            
            $newjob = Add-BitsFile -BitsJob $job -Source  $URL -Destination $Destination            
            Write-Progress -Activity "Adding file $($newjob.FilesTotal)" -Status "Percent completed: " -PercentComplete (($newjob.FilesTotal)*100/($AllURLs.Count))            
        }            
            
        # Begin the download and show us the job            
        Resume-BitsTransfer  -BitsJob $job -Asynchronous            
            
        # http://msdn.microsoft.com/en-us/library/windows/desktop/ee663885%28v=vs.85%29.aspx            
        while ($job.JobState -in @('Connecting','Transferring','Queued')) {            
            Write-Progress -activity "Downloading ADK files" -Status "Percent completed: " -PercentComplete ($job.BytesTransferred*100/$job.BytesTotal)            
        }             
        Switch($job.JobState) {            
         "Transferred" {            
                Complete-BitsTransfer -BitsJob $job            
                break            
            }            
         "Error" {            
                # List the errors.            
                $job | Format-List             
            }             
         default {            
                # Perform corrective action.            
            }             
        }            
    }            
}            
End {}            
}            
            
Get-ADKFiles -TargetFolder 'D:\Downloads\ADK'