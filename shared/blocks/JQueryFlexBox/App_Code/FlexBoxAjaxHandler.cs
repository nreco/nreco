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
using System.Data;
using System.Web.Script.Serialization;

using NReco;
using NReco.Collections;
using NReco.Web;
using NReco.Logging;
using NI.Data.Dalc;
using NI.Data.RelationalExpressions;

public class FlexBoxAjaxHandler : IHttpHandler {
	
	static ILog log = LogManager.GetLogger(typeof(FlexBoxAjaxHandler));
	
	public bool IsReusable {
		get { return true; }
	}

	public void ProcessRequest(HttpContext context) {
		var Request = context.Request;
		var Response = context.Response;
		log.Write( LogEvent.Info, "Processing FlexBox ajax request: {0}", Request.Url.ToString() );
		
		var dalcName = Request["dalc"];
		var relex = Request["relex"];
		var dalc = WebManager.GetService<IDalc>(dalcName);
		var labelField = Request["label"];
		var filterPrvName = Request["filter"];
		
		var relexParser = new RelExQueryParser(false);
		var exprResolver = WebManager.GetService<NI.Common.Expressions.IExpressionResolver>("defaultExprResolver");
		var filterPrv = filterPrvName!=null ? WebManager.GetService<IProvider<IDictionary<string,object>,IDictionary<string,object>>>(filterPrvName) : null;
		
		var qContext = new Hashtable();
		foreach (string key in Request.Params.Keys)
			if (key!=null)
				qContext[key] = Request.Params[key];
		if (Request["context"] != null) {
			var deserializedCtx = JsHelper.FromJsonString<IDictionary<string, object>>(Request["context"]);
			foreach (var item in deserializedCtx) {
				qContext[item.Key] = JsHelper.FromJsonString(Convert.ToString(item.Value));
			}
		}		
				
		Query q = (Query)relexParser.Parse( Convert.ToString( exprResolver.Evaluate( qContext, relex ) ) );
		
		if (Request["p"]!=null && Request["s"]!=null) {
			var pageSize = Convert.ToInt32(Request["s"]);
			q.StartRecord = ( Convert.ToInt32(Request["p"])-1 )*pageSize;
			q.RecordCount = pageSize;
		}
		var ds = new DataSet();
		dalc.Load(ds, q);
		
		var res = new Dictionary<string,object>();
		var results = new List<IDictionary<string,object>>();
		foreach (DataRow r in ds.Tables[q.SourceName].Rows) {
			IDictionary<string,object> data  = new Dictionary<string,object>( new DataRowDictionaryWrapper(r) );
			// process label field (if specified)
			if (!String.IsNullOrEmpty(labelField) && data.ContainsKey(labelField))
				data[labelField] = WebManager.GetLabel( Convert.ToString(data[labelField]), typeof(FlexBoxAjaxHandler).FullName);
			
			// prevent security hole
			if (data.ContainsKey("password"))
				data["password"] = null;
			
			// filter
			if (filterPrv!=null)
				data = filterPrv.Provide(data);
			if (data!=null)
				results.Add(data);
		}
		
		res["total"] = dalc.RecordsCount( q.SourceName, q.Root );
		res["results"] = results;
		
		var json = new JavaScriptSerializer();
		Response.Write( json.Serialize(res) );
	}

}