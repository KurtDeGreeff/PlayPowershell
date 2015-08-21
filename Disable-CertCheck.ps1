add-type @" 
    using System.Net; 
    using System.Security.Cryptography.X509Certificates; 
     
    public class NoSSLCheckPolicy : ICertificatePolicy { 
        public NoSSLCheckPolicy() {} 
        public bool CheckValidationResult( 
            ServicePoint sPoint, X509Certificate cert, 
            WebRequest wRequest, int certProb) { 
            return true; 
        } 
    } 
"@ 
[System.Net.ServicePointManager]::CertificatePolicy = new-object NoSSLCheckPolicy 