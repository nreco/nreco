#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2011 Vitaliy Fedorchenko
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
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;

using NReco;
using NReco.Logging;
using NReco.Collections;
using NReco.Converting;
using NReco.Web;
using NReco.Web.Site;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

public abstract class GenericView : ActionUserControl, IDataContextAware {
	
	public bool UseSessionDataContext { get; set; }
	
	static ILog log = LogManager.GetLogger(typeof(GenericView));
	
	protected string SessionDataContextKey { 
		get {
			return String.Format("dataContext#{0}#{1}",Request.Url.AbsolutePath,ClientID);
		}
	}
	
	private IDictionary<string,object> _DataContext = null;
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
				if (_DataContext==null) {
					_DataContext = new Dictionary<string,object>();
				}
				return _DataContext; 
			}
		}
		set { 
			if (UseSessionDataContext) {
				Session[SessionDataContextKey] = value;
			} else {
				_DataContext = value;
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
			return ControlExtensions.GetRouteUrl(this,routeName,context);
		} catch (Exception ex) {
			log.Write(LogEvent.Warn,ex);
			return null;
		}
	}
	
	#region ListView Handlers
	
	public int GetListViewRowCount(ListView listView) {
		var pager = listView.GetChildren<DataPager>().FirstOrDefault();
		if (pager!=null)
			return pager.TotalRowCount;
		if (listView.Items!=null)
			return listView.Items.Count;
		return -1;
	}
	
	public IList<IDictionary> GetListSelectedKeys(ListView listView) {
		var res = new List<IDictionary>();
		foreach (var idx in listView.GetChildren<System.Web.UI.HtmlControls.HtmlInputCheckBox>().Where(c=>c.Checked && !String.IsNullOrEmpty(c.Value) ).Select(c=>Convert.ToInt32(c.Value)))
			res.Add( listView.DataKeys[idx].Values );
		return res;
	}
	
	public void ListViewSortButtonPreRender(object sender, EventArgs e) {
		var button = (IButtonControl)sender;
		var ctrl = (WebControl)sender;
		// find parent list
		var list = ctrl.GetParents<ListView>().FirstOrDefault();
		if (list!=null) {
			//remove css classes
			ctrl.CssClass = ctrl.CssClass.Replace("ascending","").Replace("descending","").Trim();
			if (list.SortExpression!=null) {
				var fullSortStr = String.Format("{0} {1}", list.SortExpression, list.SortDirection==SortDirection.Ascending ? "asc" : "desc" );
				var sortField = fullSortStr.Split(',').Select( f => new QSortField(f) ).Where( f => f.Name==button.CommandArgument).FirstOrDefault();
				if (sortField!=null)
					ctrl.CssClass = ctrl.CssClass+" "+(sortField.SortDirection==ListSortDirection.Ascending ? "ascending" : "descending");
			}
		}
	}
	
	public object ListRenderGroupField(object dataItem, string groupFieldName, ref object currentGroupValue, bool updCurrentGroupVal) {
		var groupValue = DataBinder.Eval(dataItem, groupFieldName);
		if (AssertHelper.AreEqual(groupValue, currentGroupValue)) 
			return null;
		if (updCurrentGroupVal)
			currentGroupValue = groupValue;
		return groupValue;
	}
	
	#endregion
	
	public bool IsFuzzyTrue(object o) {
		return AssertHelper.IsFuzzyTrue(o);
	}
	
	public bool IsFuzzyEmpty(object o) {
		return AssertHelper.IsFuzzyEmpty(o);
	}
	
	public bool AreEquals(object o1, object o2) {
		return AssertHelper.AreEquals(o1, o2);
	}
	
	public object EvalOgnlExpression(string expr, object context) {
		var ognl = new NReco.OGNL.EvalOgnl();
		var ognlContext = context!=null ? NReco.Converting.ConvertManager.ChangeType<IDictionary<string,object>>(context) : new Dictionary<string,object>();
		return ognl.Eval(expr, ognlContext);
	}
	
	public object GetControlValue(Control container, string ctrlId) {
		var ctrl = container.FindControl(ctrlId);
		if (ctrl==null) return null;
		if (ctrl is ITextControl)
			return ((ITextControl)ctrl).Text;
		if (ctrl is ICheckBoxControl)
			return ((ICheckBoxControl)ctrl).Checked;
		throw new Exception("Cannot extract control value from "+ctrl.GetType().ToString());
	}
	public void SetControlValue(Control container, string ctrlId, object val) {
		var ctrl = container.FindControl(ctrlId);
		if (ctrl==null) return;
		if (ctrl is ITextControl)
			((ITextControl)ctrl).Text = Convert.ToString(val);
		if (ctrl is ICheckBoxControl)
			((ICheckBoxControl)ctrl).Checked = ConvertManager.ChangeType<bool>(val);
	}
	
	public IDictionary CastToDictionary(object o) {
		if (o==null) return null;
		var converter = NReco.Converting.ConvertManager.FindConverter( o.GetType(), typeof(IDictionary) );
		if (converter!=null)
			return (IDictionary)converter.Convert(o, typeof(IDictionary) );
		return new DictionaryWrapper<string,object>( new NReco.Collections.ObjectDictionaryWrapper(o) );
	}
	
	// if we initialized datacontext *before* viewstate load -> preserve those values
	protected override void LoadViewState(object savedState) {
		if (savedState is object[]) {
			var savedStateArr = (object[])savedState;
			base.LoadViewState(savedStateArr[0]);
			if (savedStateArr[1] is IDictionary<string, object>) {
				var newContext = (IDictionary<string, object>)savedStateArr[1];
				if (_DataContext != null) {
					foreach (var d in _DataContext) {
						newContext[d.Key] = d.Value;
					}
				} 
				_DataContext = newContext;
			}
		} else {
			base.LoadViewState(savedState);
		}
	}
	protected override object SaveViewState() {
		if (_DataContext != null) {
			object baseState = base.SaveViewState();
			object[] allStates = new object[2];
			allStates[0] = baseState;
			allStates[1] = _DataContext;
			return allStates;
		} else {
			return base.SaveViewState();
		}
	}

	
	#region Custom Validators
	
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
	
	#endregion
	
	
}
