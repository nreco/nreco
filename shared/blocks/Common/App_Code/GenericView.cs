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

public abstract class GenericView : ActionUserControl, IDataContextAware {

	public IDictionary<string,object> DataContext {
		get { 
			var dataCntx = ViewState["dataContext"] as IDictionary<string,object>;
			if (dataCntx==null) {
				dataCntx = new Dictionary<string,object>();
				ViewState["dataContext"] = dataCntx;
			}
			return dataCntx; 
		}
		set { 
			ViewState["dataContext"] = value;
		}
	}
	
	public bool IsFuzzyTrue(object o) {
		if (o is bool)
			return (bool)o;
		if (o==null || o==DBNull.Value)
			return false;
		if (o is string && (string)o == String.Empty)
			return false;
		if (o is ICollection)
			return ((ICollection)o).Count > 0;
		if (o is int)
			return (int)o!=0;
		if (o is decimal)
			return (decimal)o!=0;
		if (o is long)
			return (long)o!=0;
		if (o is byte)
			return (byte)o!=0;
		if (o is DateTime)
			return ((DateTime)o)!=DateTime.MinValue;
		return ConvertManager.ChangeType<bool>(o);
	}
	
}
