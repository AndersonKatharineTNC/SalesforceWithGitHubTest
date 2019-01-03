/*
Written By: Salesforce (https://developer.salesforce.com/blogs/developer-relations/2013/03/testing-apex-callouts-using-httpcalloutmock.html)
Last Updated: 2018-12-18
Purpose: Mock http callout response generator. Test classes cannot make actual callouts to external data
sources, so this code generates a mock response for use in testing. See 'GetMonitoringDocumentsTest.apxc' 
for an example of how to use this code in testing code that makes an http callout.
 */

@isTest
global class MockHttpResponseGenerator implements System.HttpCalloutMock {
    protected Integer code;
		protected String status;
		protected String bodyAsString;
		protected Blob bodyAsBlob;
		protected Map<String, String> responseHeaders;

		public MockHttpResponseGenerator(Integer code, Blob body,
                                         Map<String, String> responseHeaders) {
			this.code = code;
			this.bodyAsBlob = body;
			this.bodyAsString = null;
			this.responseHeaders = responseHeaders;
		}

	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(code);
			if (bodyAsBlob != null) {
				resp.setBodyAsBlob(bodyAsBlob);
			} else {
				resp.setBody(bodyAsString);
			}

			if (responseHeaders != null) {
			     for (String key : responseHeaders.keySet()) {
				resp.setHeader(key, responseHeaders.get(key));
			     }
			}
			return resp;
	    }
}