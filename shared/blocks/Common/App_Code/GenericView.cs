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

public abstract class GenericView : DataContextView {
	protected override bool OnBubbleEvent(object sender, EventArgs e) {
		// b/c generated buttons are not binded to event handler, lets catch their events
		if (IsBubbleEventGeneratedSender(sender, e)) {
			ButtonHandler(sender,e);
			return true;
		}
		return base.OnBubbleEvent(sender,e);
	}
	
	protected virtual bool IsBubbleEventGeneratedSender(object sender, EventArgs e) {
		return sender is IButtonControl && sender is Control && ((Control)sender).NamingContainer==this;
	}
	
	public string GetRouteUrlSafe(string routeName, IDictionary context) {
		return ViewHelper.GetRouteUrlSafe(this, routeName, context);
	}
	
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
		foreach (var idx in listView.GetChildren<System.Web.UI.HtmlControls.HtmlInputCheckBox>().Where(c => c.Checked && c.ID == "checkItem" && !String.IsNullOrEmpty(c.Value) ).Select(c=>Convert.ToInt32(c.Value)))
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
	
	public void ListViewOnPageSizeChanged(object sender, EventArgs e) {
		if (sender is Control && sender is ITextControl) {
			var pagerCtrl = ((Control)sender).GetParents<System.Web.UI.WebControls.DataPager>().First();
			pagerCtrl.SetPageProperties( 0, Convert.ToInt32( ((ITextControl)sender).Text ), true );
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
	
	public object EmptyFallback(params object[] args) {
		foreach (var o in args)
			if (!AssertHelper.IsFuzzyEmpty(o))
				return o;
		return null;
	}
	
	public object GetControlValue(Control container, string ctrlId) {
		return ViewHelper.GetControlValue(container, ctrlId);
	}
	public void SetControlValue(Control container, string ctrlId, object val) {
		ViewHelper.SetControlValue(container, ctrlId, val);
	}
	
	public IDictionary CastToDictionary(object o) {
		if (o==null) return null;
		var converter = NReco.Converting.ConvertManager.FindConverter( o.GetType(), typeof(IDictionary) );
		if (converter!=null)
			return (IDictionary)converter.Convert(o, typeof(IDictionary) );
		return new DictionaryWrapper<string,object>( new NReco.Collections.ObjectDictionaryWrapper(o) );
	}
	
	public object GetContextFieldValue(object context, string fieldName) {
		// special logic for dalc data source events
		if (context is DalcDataSourceSelectEventArgs) {
			var selectEventArgs = (DalcDataSourceSelectEventArgs)context;
			if (selectEventArgs.Data!=null && selectEventArgs.SelectQuery!=null && selectEventArgs.Data.Tables[selectEventArgs.SelectQuery.SourceName]!=null && selectEventArgs.Data.Tables[selectEventArgs.SelectQuery.SourceName].Rows.Count>0) {
				return CastToDictionary(selectEventArgs.Data.Tables[selectEventArgs.SelectQuery.SourceName].Rows[0])[fieldName];
			}
		}
		return CastToDictionary(context)[fieldName];
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