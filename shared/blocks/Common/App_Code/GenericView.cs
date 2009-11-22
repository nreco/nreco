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

	protected override bool OnBubbleEvent(object sender, EventArgs e) {
		// b/c generated buttons are not binded to event handler, lets catch their events
		if (sender is IButtonControl && sender is Control && ((Control)sender).NamingContainer==this) {
			ButtonHandler(sender,e);
			return true;
		}
		return base.OnBubbleEvent(sender,e);
	}
	
	public string GetRouteUrlSafe(string routeName, IDictionary context) {
		try {
			return this.GetRouteUrl(routeName,context);
		} catch {
			return null;
		}
	}
	
	public int GetListViewRowCount(ListView listView) {
		var pager = listView.GetChildren<DataPager>().FirstOrDefault();
		if (pager!=null)
			return pager.TotalRowCount;
		if (listView.Items!=null)
			return listView.Items.Count;
		return -1;
	}
	
	public bool IsFuzzyTrue(object o) {
		return AssertHelper.IsFuzzyTrue(o);
	}
	
	public bool IsFuzzyEmpty(object o) {
		return AssertHelper.IsFuzzyEmpty(o);
	}
	
	public bool AreEquals(object o1, object o2) {
		return AssertHelper.AreEquals(o1, o2);
	}
	
	IDictionary<string,IDictionary<CustomValidator,bool>> ChooseOneGroupCounters = new Dictionary<string,IDictionary<CustomValidator,bool>>();
	public void ChooseOneServerValidate(object source, ServerValidateEventArgs args) {
		var ctrl = (CustomValidator)source;
		var group = ctrl.Attributes["ChooseOneGroup"];
		if (!ChooseOneGroupCounters.ContainsKey(group))
			ChooseOneGroupCounters[group] = new Dictionary<CustomValidator,bool>();
		var hasValue = !String.IsNullOrEmpty(args.Value);
		ChooseOneGroupCounters[group][ctrl] = hasValue;
		// count
		var count = ChooseOneGroupCounters[group].Values.Where ( r=>r ).Count();
		args.IsValid = !hasValue || count<=1;
	}
	
	
	
}
