//Generated by wsdl2apex - Required to make the PdfGeneratorController2 class work

@isTest
public class AsyncPdfGeneratorController2_wsdl {
    public class savePdfResponse_elementFuture extends System.WebServiceCalloutFuture {
        public void getValue() {
            System.WebServiceCallout.endInvoke(this);
        }
    }
    public class AsyncPdfGeneratorController2 {
        public String endpoint_x = URL.getSalesforceBaseUrl()+'/services/Soap/class/PdfGeneratorController2';
        public Map<String,String> inputHttpHeaders_x;
        public String clientCertName_x;
        public Integer timeout_x;
        public PdfGeneratorController2_wsdl.AllowFieldTruncationHeader_element AllowFieldTruncationHeader;
        public PdfGeneratorController2_wsdl.CallOptions_element CallOptions;
        public PdfGeneratorController2_wsdl.DebuggingHeader_element DebuggingHeader;
        public PdfGeneratorController2_wsdl.SessionHeader_element SessionHeader;
        public PdfGeneratorController2_wsdl.DebuggingInfo_element DebuggingInfo;
        private String AllowFieldTruncationHeader_hns = 'AllowFieldTruncationHeader=http://soap.sforce.com/schemas/class/PdfGeneratorController2';
        private String CallOptions_hns = 'CallOptions=http://soap.sforce.com/schemas/class/PdfGeneratorController2';
        private String DebuggingHeader_hns = 'DebuggingHeader=http://soap.sforce.com/schemas/class/PdfGeneratorController2';
        private String SessionHeader_hns = 'SessionHeader=http://soap.sforce.com/schemas/class/PdfGeneratorController2';
        private String DebuggingInfo_hns = 'DebuggingInfo=http://soap.sforce.com/schemas/class/PdfGeneratorController2';
        private String[] ns_map_type_info = new String[]{'http://soap.sforce.com/schemas/class/PdfGeneratorController2', 'PdfGeneratorController2_wsdl'};
        public AsyncPdfGeneratorController2_wsdl.savePdfResponse_elementFuture beginSavePdf(System.Continuation continuation,String parentID,String pdfName) {
            PdfGeneratorController2_wsdl.savePdf_element request_x = new PdfGeneratorController2_wsdl.savePdf_element();
            request_x.parentID = parentID;
            request_x.pdfName = pdfName;
            return (AsyncPdfGeneratorController2_wsdl.savePdfResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncPdfGeneratorController2_wsdl.savePdfResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              '',
              'http://soap.sforce.com/schemas/class/PdfGeneratorController2',
              'savePdf',
              'http://soap.sforce.com/schemas/class/PdfGeneratorController2',
              'savePdfResponse',
              'PdfGeneratorController2_wsdl.savePdfResponse_element'}
            );
        }
    }
}