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
		return AssertHelper.IsFuzzyTrue(o);
	}
	
	public bool AreEquals(object o1, object o2) {
		return AssertHelper.AreEquals(o1, o2);
	}
	
}
