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
	
}
