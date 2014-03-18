/* soapClient.c
   Generated by gSOAP 2.8.17r from ows.h

Copyright(C) 2000-2013, Robert van Engelen, Genivia Inc. All Rights Reserved.
The generated code is released under one of the following licenses:
GPL or Genivia's license for commercial use.
This program is released under the GPL with the additional exemption that
compiling, linking, and/or using OpenSSL is allowed.
*/

#if defined(__BORLANDC__)
#pragma option push -w-8060
#pragma option push -w-8004
#endif
#include "soapH.h"
#ifdef __cplusplus
extern "C" {
#endif

SOAP_SOURCE_STAMP("@(#) soapClient.c ver 2.8.17r 2014-03-15 13:55:46 GMT")


SOAP_FMAC5 int SOAP_FMAC6 soap_call_ows__call(struct soap *soap, const char *soap_endpoint, const char *soap_action, char *method, char **args, struct ows__Data *in, struct ows__Data *out)
{	struct ows__call soap_tmp_ows__call;
	soap_begin(soap);
	soap->encodingStyle = NULL;
	soap_tmp_ows__call.method = method;
	soap_tmp_ows__call.args = args;
	soap_tmp_ows__call.in = in;
	soap_serializeheader(soap);
	soap_serialize_ows__call(soap, &soap_tmp_ows__call);
	if (soap_begin_count(soap))
		return soap->error;
	if (soap->mode & SOAP_IO_LENGTH)
	{	if (soap_envelope_begin_out(soap)
		 || soap_putheader(soap)
		 || soap_body_begin_out(soap)
		 || soap_put_ows__call(soap, &soap_tmp_ows__call, "ows:call", NULL)
		 || soap_body_end_out(soap)
		 || soap_envelope_end_out(soap))
			 return soap->error;
	}
	if (soap_end_count(soap))
		return soap->error;
	if (soap_connect(soap, soap_url(soap, soap_endpoint, NULL), soap_action)
	 || soap_envelope_begin_out(soap)
	 || soap_putheader(soap)
	 || soap_body_begin_out(soap)
	 || soap_put_ows__call(soap, &soap_tmp_ows__call, "ows:call", NULL)
	 || soap_body_end_out(soap)
	 || soap_envelope_end_out(soap)
	 || soap_end_send(soap))
		return soap_closesock(soap);
	if (!out)
		return soap_closesock(soap);
	soap_default_ows__Data(soap, out);
	if (soap_begin_recv(soap)
	 || soap_envelope_begin_in(soap)
	 || soap_recv_header(soap)
	 || soap_body_begin_in(soap))
		return soap_closesock(soap);
	soap_get_ows__Data(soap, out, "ows:Data", "");
	if (soap->error)
		return soap_recv_fault(soap, 0);
	if (soap_body_end_in(soap)
	 || soap_envelope_end_in(soap)
	 || soap_end_recv(soap))
		return soap_closesock(soap);
	return soap_closesock(soap);
}

#ifdef __cplusplus
}
#endif

#if defined(__BORLANDC__)
#pragma option pop
#pragma option pop
#endif

/* End of soapClient.c */
