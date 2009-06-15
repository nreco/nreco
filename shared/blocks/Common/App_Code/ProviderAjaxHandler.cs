using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Web.Script.Serialization;

using NReco;
using NReco.Web;
using NReco.Logging;
using NI.Vfs;


public class ProviderAjaxHandler : IHttpHandler {
	
	static ILog log = LogManager.GetLogger(typeof(ProviderAjaxHandler));
	
	public bool IsReusable {
		get { return true; }
	}

	public void ProcessRequest(HttpContext context) {
		var Request = context.Request;
		var Response = context.Response;
		log.Write( LogEvent.Info, "Processing request: {0}", Request.Url.ToString() );
		
		string providerName = Request["provider"];
		string contextJson = Request["context"];
		
		var provider = WebManager.GetService<IProvider<object,object>>(providerName);
		var json = new JavaScriptSerializer();
		
		var prvContext = contextJson!=null ? json.DeserializeObject(contextJson) : null;
		
		var result = provider.Provide(prvContext);
		if (result!=null)
			Response.Write( json.Serialize(result) );
	}

}