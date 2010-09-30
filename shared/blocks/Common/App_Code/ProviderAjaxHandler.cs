#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008,2009 Vitaliy Fedorchenko
 * Distributed under the LGPL licence
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#endregion

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Globalization;
using System.Threading;
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
		try {
			var Request = context.Request;
			var Response = context.Response;
			log.Write( LogEvent.Info, "Processing request: {0}", Request.Url.ToString() );
			
			string providerName = Request["provider"];
			string contextJson = Request["context"];
			string langCode = Request["language"];
			try {
				if (!String.IsNullOrEmpty(langCode))
					Thread.CurrentThread.CurrentCulture = Thread.CurrentThread.CurrentUICulture = CultureInfo.GetCultureInfo(langCode);		
			} catch {
				log.Write( LogEvent.Warn, "Cannot apply language settings (language: {0}, request: {1})", langCode, Request.Url.ToString() );
			}
			
			var json = new JavaScriptSerializer();
			var prvContext = contextJson!=null ? json.DeserializeObject(contextJson) : null;
			
			var provider = WebManager.GetService<IProvider<object,object>>(providerName);
			if (provider!=null) {
				var result = provider.Provide(prvContext);
				if (result!=null)
					Response.Write( json.Serialize(result) );
			} else {
				// maybe operation?
				var op = WebManager.GetService<IOperation<object>>(providerName);
				if (op!=null) {
					op.Execute(prvContext);
				} else {
					throw new Exception("Unknown service: "+providerName);
				}
			}
		} catch (Exception ex) {
			log.Write(LogEvent.Warn, String.Format("exception={0}, url={1}", ex, context.Request.Url) );
			
			context.Response.Write(ex.Message);
			context.Response.StatusCode = 510; /*custom code:ajax error*/
		}		
	}

}