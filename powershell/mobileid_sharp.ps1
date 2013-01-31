# mobileid_sharp.ps1 - 1.0
#
# Generic script to invoke Swisscom Mobile ID service.
# Minimum PowerShell version : 2.0
#
# Description :
# First part  - line 14  / param aquisiton
# Second part - line 21  / C# class SwisscomMobileID.cs
# Third part  - line 414 / Processing
# 
# Change Log  :
#  1.0 31.10.2012: Initial version with signature validation

param([string]$Verbose = "", [string]$PhoneNumber = "", [string]$Message = "", [string]$Language = "")


################################################################################
# SwisscomMobileID.cs
################################################################################

$source = @"
using System;
using System.IO;
using System.Net;
using System.Text;
using System.Security.Cryptography;
using System.Security.Cryptography.Pkcs;
using System.Security.Cryptography.X509Certificates;
using System.Xml;


namespace Swisscom
{
  public class SwisscomMobileID
  {
    private const string SWISSCOM_SERVICE_URL = "https://soap.mobileid.swisscom.com/soap/services/MSS_SignaturePort";
    private const string CRLF = "\r\n";

    private bool verbose = false;
    private bool debug = false;
    private string phoneNumber = string.Empty;
    private string message = string.Empty;
    private string language = string.Empty;

    private string cert_filePfx = string.Empty;
    private string ap_id = string.Empty;

    private string ap_pwd = string.Empty;
    private string cert_ca = string.Empty;
    private string ocsp_cert = string.Empty;
    private string ocsp_url = string.Empty;

    private string ap_transID = string.Empty;
    private string ap_instant = string.Empty;

    private string res_transID = string.Empty;
    private string res_msisdnid = string.Empty;
    private string res_msg = string.Empty;
    private string res_msg_status = string.Empty;
    private string res_id_cert = string.Empty;
    private string res_rc = string.Empty;
    private string res_st = string.Empty;
    private int rc = 0;

    // Working variables
    private string workingFolder;
    private string soap_xml_post;
    private string soap_xml_response;
    private string friendly_error_msg;
    private string framework_error_msg;

    #region Constructor
    public SwisscomMobileID(bool v, string mobileNumber, string msg, string lng, string folder)
    {
      verbose = v;
      phoneNumber = mobileNumber;
      message = msg;
      language = lng;
      workingFolder = folder;
    }
    #endregion

    #region Execute
    public string Execute()
    {
      try
      {
        friendly_error_msg = string.Empty;

        InitializeCertificateLocation();
        InitializeApplicationProviderInfos();
        InitializeSoapData();
        PostXmlToWebService();
        return VerboseDetails();
      }
      catch (Exception ex)
      {
        return DisplayException();
      }
    }
    #endregion

    #region Debug
    public string Debug()
    {
      return "Hello from SwisscomMobileID : Timestamp ["+ DateTime.Now +"]";
    }
    #endregion

    #region DebugParam
    public string DebugParam()
    {      
      StringBuilder sb = new StringBuilder();
      sb.Append("Verbose mode ... : [" + verbose.ToString() + "]" + CRLF);
      sb.Append("Mobile number ...: [" + phoneNumber + "]" + CRLF);
      sb.Append("Message .........: [" + message + "]" + CRLF);
      sb.Append("Language ........: [" + language + "]" + CRLF);
      sb.Append("Working folder ..: [" + workingFolder + "]" + CRLF);

      return sb.ToString();
    }
    #endregion

    #region InitializeCertificateLocation
    private void InitializeCertificateLocation()
    {
      // User Certificates
      cert_filePfx = System.IO.Path.Combine(workingFolder, "mycert.pfx");

      // Swisscom Certificates
      cert_ca = System.IO.Path.Combine(workingFolder, "swisscom-ca.crt");
      ocsp_cert = System.IO.Path.Combine(workingFolder, "swisscom-ocsp.crt");
      ocsp_url = "http://ocsp.swissdigicert.ch/sdcs-rubin2";

      if (!File.Exists(cert_filePfx))
      {
        friendly_error_msg = "The file [" + cert_filePfx + "] doesn't exists";
        throw new System.IO.FileNotFoundException();
      }

      if (!File.Exists(cert_ca))
      {
        friendly_error_msg = "The file [" + cert_ca + "] doesn't exists";
        throw new System.IO.FileNotFoundException();
      }
    }
    #endregion

    #region InitializeApplicationProviderInfos
    private void InitializeApplicationProviderInfos()
    {
      ap_id = "http://iam.swisscom.ch";
      ap_pwd = "disabled";

      System.Random rndNumber = new System.Random();
      ap_transID = "AP.TEST." + rndNumber.Next(10000, 99999).ToString() + "." + rndNumber.Next(1000, 9999).ToString();
      ap_instant = string.Format("{0:yyyy-MM-ddTHH:mm:ss}", System.DateTime.Now);
    }
    #endregion

    #region InitializeSoapData
    private string InitializeSoapData()
    {
      System.Text.StringBuilder sb = new System.Text.StringBuilder();
      sb.Append(@"
      <soapenv:Envelope
          xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" 
          xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" 
          soap:encodingStyle=""http://schemas.xmlsoap.org/soap/encoding/"" 
          xmlns:soapenv=""http://www.w3.org/2003/05/soap-envelope"" 
          xmlns:soap=""http://schemas.xmlsoap.org/soap/envelope/"">
        <soapenv:Body>
          <MSS_Signature xmlns="""">
            <mss:MSS_SignatureReq MinorVersion=""1"" MajorVersion=""1"" xmlns:mss=""http://uri.etsi.org/TS102204/v1.1.2#"" MessagingMode=""synch"" TimeOut=""80"" xmlns:fi=""http://mss.ficom.fi/TS102204/v1.0.0#"">
              <mss:AP_Info AP_PWD=""disabled"" AP_TransID=""{0}"" Instant=""{1}"" AP_ID=""{2}"" />
              <mss:MSSP_Info>
                <mss:MSSP_ID/>
              </mss:MSSP_Info>
              <mss:MobileUser>
                <mss:MSISDN>{3}</mss:MSISDN>
              </mss:MobileUser>
              <mss:DataToBeSigned MimeType=""text/plain"" Encoding=""UTF-8"">{4}</mss:DataToBeSigned>
              <mss:SignatureProfile>
                <mss:mssURI>http://mid.swisscom.ch/MID/v1/AuthProfile1</mss:mssURI>
              </mss:SignatureProfile>
              <mss:AdditionalServices>
                <mss:Service>
                  <mss:Description>
                    <mss:mssURI>http://uri.etsi.org/TS102204/v1.1.2#validate</mss:mssURI>
                  </mss:Description>
                </mss:Service>
                <mss:Service>
                  <mss:Description>
                    <mss:mssURI>http://mss.ficom.fi/TS102204/v1.0.0#userLang</mss:mssURI>
                  </mss:Description>
                  <fi:UserLang>{5}</fi:UserLang>
                </mss:Service>
              </mss:AdditionalServices>
              <mss:MSS_Format>
                <mss:mssURI>http://uri.etsi.org/TS102204/v1.1.2#PKCS7</mss:mssURI>
              </mss:MSS_Format>
            </mss:MSS_SignatureReq>
          </MSS_Signature>
        </soapenv:Body>
      </soapenv:Envelope>");

      string rawXml = sb.ToString();
      rawXml = string.Format(rawXml, ap_transID, ap_instant, ap_id, phoneNumber, message, language);
      

      soap_xml_post = rawXml;

      return soap_xml_post;
    }
    #endregion

    #region PostXmlToWebService
    private void PostXmlToWebService()
    {
      X509Certificate certificatePFX = X509Certificate.CreateFromCertFile(cert_filePfx);
      X509Certificate certificateCA = X509Certificate.CreateFromCertFile(cert_ca);

      // SSL V3
      ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3;

      HttpWebRequest request = (HttpWebRequest)WebRequest.Create(SWISSCOM_SERVICE_URL);

      #region Web request
      try
      {        
        request.ClientCertificates.Add(certificatePFX);
        request.ClientCertificates.Add(certificateCA);

        request.Method = WebRequestMethods.Http.Post;
        request.ContentType = "text/xml";
        request.Headers.Add("SOAPAction", "#MSS_Signature");

        string strReq = @"<?xml version=""1.0"" encoding=""UTF-8""?>" + soap_xml_post;
        UTF8Encoding encoding = new UTF8Encoding();
        byte[] postBytes = encoding.GetBytes(strReq);

        request.ContentLength = postBytes.Length;
        Stream postStream = request.GetRequestStream();
        postStream.Write(postBytes, 0, postBytes.Length);
        postStream.Close();
      }
      catch (Exception ex)
      {
        friendly_error_msg = "Web request exception";
        framework_error_msg = ex.Message;
        throw ex;
      }

      #endregion

      #region Get And Parse Response
      string result = string.Empty;
      rc = 0;
      try
      {
        HttpWebResponse response = (HttpWebResponse)request.GetResponse();

        Encoding responseEncoding = Encoding.GetEncoding(response.CharacterSet);
        using (StreamReader sr = new StreamReader(response.GetResponseStream(), responseEncoding))
        {
          result = sr.ReadToEnd();
          ParseResponse(result);
        }
      }
      catch (WebException ex)
      {
        rc = 2; // Error
        friendly_error_msg = "Web service error. Check XML server response for further details";
        framework_error_msg = ex.Message;
        using (WebResponse response = ex.Response)
        {
          HttpWebResponse httpResponse = (HttpWebResponse)response;

          using (Stream data = response.GetResponseStream())
          {
            // XML server response
            soap_xml_response = new StreamReader(data).ReadToEnd();
            framework_error_msg = ex.Message;
            throw ex;
          }
        }
      }
      #endregion
    }
    #endregion

    #region ParseResponse
    private void ParseResponse(string rawResponse)
    {
      // Load response in xml document
      XmlDocument doc = new XmlDocument();
      doc.XmlResolver = null;
      doc.Load(new StringReader(rawResponse));

      // Namespace manager
      XmlNamespaceManager manager = new XmlNamespaceManager(doc.NameTable);
      manager.AddNamespace("soapenv", "http://www.w3.org/2003/05/soap-envelope");
      manager.AddNamespace("mss", "http://uri.etsi.org/TS102204/v1.1.2#");

      // Value of AP_TransID in XML
      XmlNodeList nodeList = doc.SelectNodes("//@AP_TransID");
      foreach (XmlNode node in nodeList)
        res_transID = node.Value;

      XmlNode aNode = null;
      // Value of MSISDN in XML
      aNode = doc.SelectSingleNode("/soapenv:Envelope/soapenv:Body/MSS_SignatureResponse/mss:MSS_SignatureResp/mss:MobileUser/mss:MSISDN", manager);
      res_msisdnid = aNode.InnerText;

      // Value of StatusCode in XML
      aNode = doc.SelectSingleNode("/soapenv:Envelope/soapenv:Body/MSS_SignatureResponse/mss:MSS_SignatureResp/mss:Status/mss:StatusCode", manager);
      res_rc = aNode.Attributes["Value"].Value;

      // Value of StatusMessage in XML
      aNode = doc.SelectSingleNode("/soapenv:Envelope/soapenv:Body/MSS_SignatureResponse/mss:MSS_SignatureResp/mss:Status/mss:StatusMessage", manager);
      res_st = aNode.InnerText;

      // Value of Signature in XML
      #region Decode Base 64 Signature and check validity
      aNode = doc.SelectSingleNode("/soapenv:Envelope/soapenv:Body/MSS_SignatureResponse/mss:MSS_SignatureResp/mss:MSS_Signature/mss:Base64Signature", manager);
      byte[] todecode_byte = Convert.FromBase64String(aNode.InnerText);

      X509Certificate certificateCA = X509Certificate2.CreateFromCertFile(cert_ca);
      X509Certificate2 cert2 = new X509Certificate2(certificateCA);

      // Verify Signature
      bool isSignatureValid = VerifySignature(todecode_byte, cert2);
      if (!isSignatureValid) throw new CryptographicException();
      #endregion
    }
    #endregion

    #region VerifySignature
    private bool VerifySignature(byte[] signature, X509Certificate2 certificate)
    {
      if (signature == null) throw new ArgumentNullException("signature");
      if (certificate == null) throw new ArgumentNullException("certificate");

      // Decode the signature
      SignedCms verifyCms = new SignedCms();

      verifyCms.Decode(signature);

      res_id_cert = verifyCms.Certificates[0].Subject;
      res_msg = System.Text.Encoding.UTF8.GetString(verifyCms.ContentInfo.Content);

      // Verify it
      try
      {
        verifyCms.CheckSignature(new X509Certificate2Collection(certificate), false);
        return true;
      }
      catch (CryptographicException ex)
      {
        rc = 3;
        friendly_error_msg = "Cryptographic exception";
        res_msg_status = ex.Message;
        return false;
      }
    }
    #endregion

    #region VerboseDetails
    private string VerboseDetails()
    {
      StringBuilder sb = new StringBuilder();

      if (verbose)
      {
        sb.Append("OK with following details and checks:" + CRLF);
        sb.Append(" 1) Transaction ID : [" + res_transID + "]");
        if (res_transID == ap_transID) sb.Append(" -> same as in request" + CRLF);
        else sb.Append(" -> different as in request!" + CRLF);
        sb.Append(" 2) Signed by      : [" + res_msisdnid + "]");
        if (res_msisdnid == phoneNumber) sb.Append(" -> same as in request" + CRLF);
        else sb.Append(" -> different as in request!" + CRLF);
        sb.Append(" 3) Time to sign   : <Not verified>" + CRLF);
        sb.Append(" 4) Signer         : [" + res_id_cert + "] -> OCSP check: [" + res_msg_status + "]" + CRLF);
        sb.Append(" 5) Signed Data    : [" + res_msg + "] -> Decode and verify: [" + res_msg_status + "] and ");
        if (res_msisdnid == phoneNumber) sb.Append(" -> same as in request" + CRLF);
        else sb.Append(" -> different as in request!" + CRLF);
        sb.Append(" 6) Status code    : [" + res_rc + "] with exit [" + res_rc + "]" + CRLF);
        sb.Append("    Status details : [" + res_st + "]" + CRLF);
      }

      return sb.ToString();
    }
    #endregion

    #region DisplayException
    private string DisplayException()
    {
      StringBuilder sb = new StringBuilder();

      sb.Append("ERROR" + CRLF);
      sb.Append("Friendly error message : [" + friendly_error_msg + "]" + CRLF);
      sb.Append("Framework error message : [" + framework_error_msg + "]" + CRLF);
      return sb.ToString();
    }
    #endregion
  }
}
"@

################################################################################

if ($PhoneNumber -ne "" -and $Message -ne "" -and $Language -ne "")
{
  $Assem = ("System.Xml", "System.Security") 
  Add-Type -TypeDefinition $source -ReferencedAssemblies $Assem -IgnoreWarnings

  $currentPath = $(Split-Path $myInvocation.MyCommand.Path)
  $mid = New-Object Swisscom.SwisscomMobileID($Verbose, $PhoneNumber, $Message, $Language, $currentPath)
  Write-Host $mid.Execute()
}
else
{
  $scriptName = $myInvocation.MyCommand.Name 
  Write-Host "Usage: $scriptName <args> -PhoneNumber <mobileNumber> -Message ""Message to be signed"" -Language <userlang>"
  Write-Host " -Verbose     : verbose output (0 or 1)"
  Write-Host " -Language    : user language (one of en, de, fr, it)"
  Write-Host
  Write-Host "Example $scriptName -Verbose 1 -PhoneNumber +41792080401 -Message ""Do you want to login to corporate VPN?"" -Language en"
}

