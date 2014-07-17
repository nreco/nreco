#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2014 Vitaliy Fedorchenko
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
using System.Web.Routing;
using System.Text;
using System.Linq;

using NReco;
using NReco.Application.Web;
using NReco.Logging;
using NI.Vfs;
using NI.Ioc;
using NReco.Dsm.WebForms;

namespace NReco.Dsm.WebForms.Bootstrap { 

	public class SelectBoxHandler : IHttpHandler {
	
		static ILog log = LogManager.GetLogger(typeof(SelectBoxHandler));
	
		public bool IsReusable {
			get { return true; }
		}
	
		public virtual void ProcessRequest(HttpContext context) {
			try {
				ProcessRequestInternal(context);
			} catch (Exception ex) {
				log.Write(LogEvent.Error,ex);
				var errMsg = AppContext.GetLabel( ex.Message );
				context.Response.StatusCode = 500;
				context.Response.StatusDescription = errMsg;
			}
		}

		protected virtual void ProcessRequestInternal(HttpContext context) {
			var providerName = context.Request["provider"];
			if (String.IsNullOrEmpty(providerName))
				throw new Exception("Parameter missed: provider");
			int start = 0;
			if (context.Request["start"]!=null)
				Int32.TryParse(context.Request["start"], out start);
			int limit = 10;
			if (context.Request["limit"]!=null)
				Int32.TryParse(context.Request["limit"], out limit);

			var providerContext = new Dictionary<string,object>();
			providerContext["start"] = start;
			providerContext["limit"] = limit;
			providerContext["q"] = context.Request["q"];

			var prv = AppContext.ComponentFactory.GetComponent<Func<IDictionary<string,object>,IEnumerable>>(providerName);
			if (prv==null)
				throw new Exception(String.Format("Provider '{0}' not found", providerName));

			var data = prv(providerContext);
			context.Response.ContentType = "application/json";
			context.Response.Write( JsUtils.ToJsonString( new Dictionary<string,object>() {
				{"data", data}
			}) );
		}

	}


}