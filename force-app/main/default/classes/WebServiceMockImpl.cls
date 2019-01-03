/*
Written by: Katharine Anderson
Last updated: 12-27-2018
Purpose: Mock callout to the webservice in the apex class PdfGeneratorController2.
https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_callouts_wsdl2apex_testing.htm
*/
@isTest
global class WebServiceMockImpl  implements System.WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
	   PdfGeneratorController2_wsdl.savePdf_element responseElement = new PdfGeneratorController2_wsdl.savePdf_element();
       responseElement.parentID = 'Mock response';
       responseElement.pdfName  = 'Mock response';
       response.put('response_x', responseElement); 
   }
}