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
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;

using NReco;
using NReco.Collections;
using NReco.Converting;
using NReco.Web;
using NReco.Web.Site;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

public static class DataSourceHelper  {

	public static ICollection GetProviderDataSource(string prvName, object context) {
		var datasource = WebManager.GetService<IProvider<object, IEnumerable>>(prvName).Provide(context); // tbd - contexts
		var list = new List<object>();
		foreach (var elem in datasource) {
			if (elem is IDictionary)
				list.Add( new DictionaryView( (IDictionary)elem ) );
			else
				list.Add(elem);
		}
		return list;
	}
	
	public static IDictionary GetProviderDictionary(string prvName, object context, bool useCache) {
		var prv = WebManager.GetService<IProvider<object, IDictionary>>(prvName);
		return GetProviderResult(prvName, context, useCache, 
					x => prv.Provide(x) ) as IDictionary;
	}
	
	public static IDictionary[] GetProviderDictionaries(string prvName, object context, bool useCache) {
		var prv = WebManager.GetService<IProvider<object, IDictionary[]>>(prvName);
		return GetProviderResult(prvName, context, useCache, 
					x => prv.Provide(x) ) as IDictionary[];
	}	
	
	public static bool GetProviderBoolean(string prvName, object context, bool useCache) {
		var prv = WebManager.GetService<IProvider<object, object>>(prvName);
		var res = GetProviderResult(prvName, context, useCache, 
					x => prv.Provide(x));
		return AssertHelper.IsFuzzyTrue(res);
	}
	
	public static object GetProviderObject(string prvName, object context, bool useCache) {
		var prv = WebManager.GetService<IProvider<object, object>>(prvName);
		return GetProviderResult(prvName, context, useCache, 
					x => prv.Provide(x));
	}
		
	public static object GetProviderResult(string prvName, object context, bool useCache, Func<object,object> callProvider) {
		if (useCache) {
			var cache = HttpContext.Current.Items["DataSourceHelper.GetProviderDictionary"] as IDictionary<string,object>;
			var key = prvName+"|"+JsHelper.ToJsonString(context);
			if (cache==null) {
				cache = new Dictionary<string,object>();
				HttpContext.Current.Items["DataSourceHelper.GetProviderDictionary"] = cache;
			}
			if (cache.ContainsKey(key)) {
				return cache[key];
			} else {
				var res = callProvider(context);
				cache[key] = res;
				return res;
			}
		}
		return callProvider(context);
	}
	
	
}
