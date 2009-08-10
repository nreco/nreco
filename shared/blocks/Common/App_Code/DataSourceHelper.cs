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

	public static IEnumerable GetProviderDataSource(string prvName, object context) {
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
	
	static NI.Common.Caching.UniqueCacheKeyProvider CacheKeyPrv = new NI.Common.Caching.UniqueCacheKeyProvider();
	
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
	
	public static object GetProviderResult(string prvName, object context, bool useCache, Func<object,object> callProvider) {
		if (useCache) {
			var cache = HttpContext.Current.Items["DataSourceHelper.GetProviderDictionary"] as IDictionary<string,object>;
			var key = prvName+"|"+CacheKeyPrv.GetString(context);
			if (cache==null) {
				cache = new Dictionary<string,object>();
				HttpContext.Current.Items["DataSourceHelper.GetProviderDictionary"] = cache;
			}
			if (cache.ContainsKey(key)) {
				return (IDictionary)cache[key];
			} else {
				var res = callProvider(context);
				cache[key] = res;
				return res;
			}
		}
		return callProvider(context);
	}
	
	
}
