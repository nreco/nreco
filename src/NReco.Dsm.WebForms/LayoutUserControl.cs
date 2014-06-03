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
using NI.Data;
using NI.Data.Web;
using NI.Data.Linq;

namespace NReco.Dsm.WebForms {

	public abstract class LayoutUserControl : DataContextUserControl {

		static ILog log = LogManager.GetLogger(typeof(LayoutUserControl));

		protected override bool OnBubbleEvent(object sender, EventArgs e) {
			// b/c generated buttons are not binded to event handler, lets catch their events
			if (IsBubbleEventGeneratedSender(sender, e)) {
				ButtonHandler(sender, e);
				return true;
			}
			return base.OnBubbleEvent(sender, e);
		}

		protected virtual bool IsBubbleEventGeneratedSender(object sender, EventArgs e) {
			return sender is IButtonControl && sender is Control && ((Control)sender).NamingContainer == this;
		}

		public string GetRouteUrlSafe(string routeName, IDictionary context) {
			try {
				return GetRouteUrl(routeName,
					new System.Web.Routing.RouteValueDictionary(
						new DictionaryGenericWrapper<string, object>(context)));
			} catch (Exception ex) {
				log.Write(LogEvent.Debug, ex);
				return null;
			}
		}

		public int GetListViewRowCount(System.Web.UI.WebControls.ListView listView) {
			var pager = ControlUtils.GetChildren<DataPager>(listView).FirstOrDefault();
			if (pager != null)
				return pager.TotalRowCount;
			if (listView.Items != null)
				return listView.Items.Count;
			return -1;
		}

		public IList<object> GetListSelectedKeys(System.Web.UI.WebControls.ListView listView) {
			var res = new List<object>();
			foreach (var idx in ControlUtils.GetChildren<System.Web.UI.HtmlControls.HtmlInputCheckBox>(listView).Where(c => c.Checked && c.ID == "checkItem" && !String.IsNullOrEmpty(c.Value)).Select(c => Convert.ToInt32(c.Value)))
				res.Add( listView.DataKeys[idx].Values.Count>1 ? listView.DataKeys[idx].Values : listView.DataKeys[idx].Value);
			return res;
		}

		public void ListViewSortButtonPreRender(object sender, EventArgs e) {
			var button = (IButtonControl)sender;
			var ctrl = (WebControl)sender;
			// find parent list
			var list = ControlUtils.GetParents<ListView>(ctrl).FirstOrDefault();
			if (list != null) {
				//remove css classes
				ctrl.CssClass = ctrl.CssClass.Replace("ascending", "").Replace("descending", "").Trim();
				if (list.SortExpression != null) {
					var fullSortStr = String.Format("{0} {1}", list.SortExpression, list.SortDirection == SortDirection.Ascending ? "asc" : "desc");
					var sortField = fullSortStr.Split(',').Select(f => new QSort(f)).Where(f => f.Field.Name == button.CommandArgument).FirstOrDefault();
					if (sortField != null)
						ctrl.CssClass = ctrl.CssClass + " " + (sortField.SortDirection == ListSortDirection.Ascending ? "ascending" : "descending");
				}
			}
		}

		public void ListViewOnPageSizeChanged(object sender, EventArgs e) {
			if (sender is Control && sender is ITextControl) {
				var pagerCtrl = ControlUtils.GetParents<System.Web.UI.WebControls.DataPager>((Control)sender).First();
				pagerCtrl.SetPageProperties(0, Convert.ToInt32(((ITextControl)sender).Text), true);
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

		public bool AreEqual(object o1, object o2) {
			return AssertHelper.AreEqual(o1, o2);
		}

		public object EvalLambdaExpression(string expr, object context) {
			var lambdaParser = new NReco.Linq.LambdaParser();
			var ognlContext = context != null ? NReco.Converting.ConvertManager.ChangeType<IDictionary<string, object>>(context) : new Dictionary<string, object>();
			return lambdaParser.Eval(expr, ognlContext);
		}

		public object EmptyFallback(params object[] args) {
			foreach (var o in args)
				if (!AssertHelper.IsFuzzyEmpty(o))
					return o;
			return null;
		}

		public object GetFuncResult(Delegate func, string funcName, bool cache, params object[] args) {
			if (cache) {
				var cacheDictionary = Page.Items["GetFuncResultCache"] as IDictionary<string, object>;
				var key = funcName + "|" + JsUtils.ToJsonString(args);
				if (cacheDictionary == null) {
					cacheDictionary = new Dictionary<string, object>();
					Page.Items["GetFuncResultCache"] = cacheDictionary;
				}
				if (cacheDictionary.ContainsKey(key)) {
					return cacheDictionary[key];
				} else {
					var res = func.DynamicInvoke(args);
					cacheDictionary[key] = res;
					return res;
				}
			}
			return func.DynamicInvoke(args);
		}

		public object GetControlValue(Control container, string ctrlId) {
			return ControlUtils.GetControlValue(container, ctrlId);
		}
		public void SetControlValue(Control container, string ctrlId, object val) {
			ControlUtils.SetControlValue(container, ctrlId, val);
		}

		public IDictionary CastToDictionary(object o) {
			if (o == null)
				return null;
			var converter = NReco.Converting.ConvertManager.FindConverter(o.GetType(), typeof(IDictionary));
			if (converter != null)
				return (IDictionary)converter.Convert(o, typeof(IDictionary));
			return new DictionaryWrapper<string, object>(new NReco.Collections.ObjectDictionaryWrapper(o));
		}

		public object GetContextFieldValue(object context, string fieldName) {
			// special logic for dalc data source events
			if (context is DalcDataSourceSelectEventArgs) {
				var selectEventArgs = (DalcDataSourceSelectEventArgs)context;
				if (selectEventArgs.Data != null && selectEventArgs.SelectQuery != null && selectEventArgs.Data.Tables[selectEventArgs.SelectQuery.Table.Name] != null && selectEventArgs.Data.Tables[selectEventArgs.SelectQuery.Table.Name].Rows.Count > 0) {
					return CastToDictionary(selectEventArgs.Data.Tables[selectEventArgs.SelectQuery.Table.Name].Rows[0])[fieldName];
				}
			}
			return CastToDictionary(context)[fieldName];
		}

		IDictionary<string, IDictionary<CustomValidator, bool>> ChooseOneGroupCounters = new Dictionary<string, IDictionary<CustomValidator, bool>>();
		public void ChooseOneServerValidate(object source, ServerValidateEventArgs args) {
			var ctrl = (CustomValidator)source;
			args.IsValid = false;

			var group = ctrl.Attributes["ChooseOneGroup"];
			if (!ChooseOneGroupCounters.ContainsKey(group))
				ChooseOneGroupCounters[group] = new Dictionary<CustomValidator, bool>();
			var hasValue = !String.IsNullOrEmpty(args.Value);
			ChooseOneGroupCounters[group][ctrl] = hasValue;
			// count
			var count = ChooseOneGroupCounters[group].Values.Where(r => r).Count();
			if (count > 0) {
				// mark all as valid
				args.IsValid = true;
				foreach (var chooseOneValidator in ChooseOneGroupCounters[group].Keys) {
					chooseOneValidator.IsValid = true;
				}
			};
		}


	}

}