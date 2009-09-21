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
	
	public bool UseSessionDataContext { get; set; }
	
	protected string SessionDataContextKey { 
		get {
			return String.Format("dataContext#{0}#{1}",Request.Url.AbsolutePath,ClientID);
		}
	}
	
	public IDictionary<string,object> DataContext {
		get { 
			if (UseSessionDataContext) {
				var dataCntx = Session[SessionDataContextKey] as IDictionary<string,object>;
				if (dataCntx==null) {
					dataCntx = new Dictionary<string,object>();
					Session[SessionDataContextKey] = dataCntx;
				}				
				return dataCntx;
			} else {
				var dataCntx = ViewState["dataContext"] as IDictionary<string,object>;
				if (dataCntx==null) {
					dataCntx = new Dictionary<string,object>();
					ViewState["dataContext"] = dataCntx;
				}
				return dataCntx; 
			}
		}
		set { 
			if (UseSessionDataContext) {
				Session[SessionDataContextKey] = value;
			} else {
				ViewState["dataContext"] = value;
			}
		}
	}
	
	public GenericView() {
		UseSessionDataContext = false;
	}
	
	public bool IsFuzzyTrue(object o) {
		return AssertHelper.IsFuzzyTrue(o);
	}
	
	public bool AreEquals(object o1, object o2) {
		return AssertHelper.AreEquals(o1, o2);
	}
	
}
