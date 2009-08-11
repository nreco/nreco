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
using System.Web.UI.WebControls;
using System.Web.Routing;
using NReco;
using NReco.Converting;
using NReco.Logging;
using NReco.Collections;

namespace NReco.Web.Site {
	
	/// <summary>
	/// Control class extensions.
	/// </summary>
	public static class ControlExtensions {

		static ILog log = LogManager.GetLogger(typeof(ControlExtensions));

		/// <summary>
		/// Returns current route context if available.
		/// </summary>
		/// <remarks>
		/// When current page is RoutePage this method returns context composed from route data.
		/// </remarks>
		public static IDictionary<string, object> GetRouteContext(this Control ctrl) {
			if (ctrl.Page is RoutePage)
				return ((RoutePage)ctrl.Page).RouteContext;
			return null;
		}

		/// <summary>
		/// Returns context object for this control.
		/// </summary>
		/// <param name="ctrl"></param>
		/// <returns></returns>
		public static ControlContext GetContext(this Control ctrl) {
			return new ControlContext(ctrl);
		}

		/// <summary>
		/// Composes URL from named route.
		/// </summary>
		public static string GetRouteUrl(this Control ctrl, string routeName) {
			return GetRouteUrl(ctrl, routeName, (IDictionary<string,object>)null);
		}

		/// <summary>
		/// Composes URL from named route using given key and value and one-entry context.
		/// </summary>
		/// <param name="routeName">name of route</param>
		/// <param name="oneKey">context entry key</param>
		/// <param name="oneValue">context entry value</param>
		/// <returns>URL or null if route is not found</returns>
		public static string GetRouteUrl(this Control ctrl, string routeName, string oneKey, object oneValue) {
			IDictionary<string,object> cntx = new Dictionary<string, object> { { oneKey, oneValue } };
			return GetRouteUrl(ctrl, routeName, cntx);
		}

		/// <summary>
		/// Composes URL from named route using given context.
		/// </summary>
		public static string GetRouteUrl(this Control ctrl, string routeName, IDictionary context) {
			var cntx = ConvertManager.ChangeType<IDictionary<string, object>>(context);
			return GetRouteUrl(ctrl, routeName, cntx);
		}

		/// <summary>
		/// Composes URL from named route using given context.
		/// </summary>
		public static string GetRouteUrl(this Control ctrl, string routeName, IDictionary<string,object> context) {
			var routeContext = context!=null ? new RouteValueDictionary(context) : new RouteValueDictionary();
			if (routeName != null) {
				var vpd = RouteTable.Routes.GetVirtualPath(null, routeName, routeContext);
				if (vpd == null) {
					log.Write(LogEvent.Error, "Route not found (route={0})", routeName);
					throw new NullReferenceException("Route with name " + routeName + " not found");
				}
				int paramStart = vpd.VirtualPath.IndexOf('?');
				return paramStart >= 0 ? vpd.VirtualPath.Substring(0, paramStart) : vpd.VirtualPath;
			}
			return null;
		}

		/// <summary>
		/// Composes URL from named route using given object's properties as context.
		/// </summary>
		public static string GetRouteUrl(this Control ctrl, string routeName, object context) {
			if (context is IDictionary || context==null)
				return GetRouteUrl(ctrl, routeName, (IDictionary)context);
			return GetRouteUrl(ctrl, routeName, new ObjectDictionaryWrapper(context));
		}

		/// <summary>
		/// Returns control parents axis of specified type.
		/// </summary>
		/// <returns>control parents axis ordered from direct parent to control tree root</returns>
		public static IEnumerable<T> GetParents<T>(this Control ctrl)  {
			while (ctrl.Parent != null) {
				ctrl = ctrl.Parent;
				if (ctrl is T)
					yield return (T)((object)ctrl);
			}
		}

		/// <summary>
		/// Returns control childres of specified type.
		/// </summary>
		/// <remarks>
		/// This method performs breadth-first search (that can avoid full subtree traversal for some cases)
		/// and doesn't uses much memory even for huge subtrees.
		/// </remarks>
		public static IEnumerable<T> GetChildren<T>(this Control ctrl) {
			var q = new Queue<Control>();
			for (int i = 0; i < ctrl.Controls.Count; i++)
				q.Enqueue(ctrl.Controls[i]);
			while (q.Count>0) {
				var c = q.Dequeue();
				if (c is T)
					yield return (T)((object)c);
				for (int i = 0; i < c.Controls.Count; i++)
					q.Enqueue(c.Controls[i]);
			}
		}

		public static void SetSelectedItems(this ListControl ctrl, string[] values) {
			SetSelectedItems(ctrl, values, false);
		}

		public static void SetSelectedItems(this ListControl ctrl, string[] values, bool preserveOrder) {
			if (preserveOrder) {
				int i = 0;
				foreach (string val in values) {
					var itm = ctrl.Items.FindByValue(values[i]);
					itm.Selected = true;
					ctrl.Items.Remove(itm);
					ctrl.Items.Insert(i++, itm);
				}
			} else {
				foreach (ListItem itm in ctrl.Items)
					itm.Selected = values.Contains(itm.Value);
			}
		}
		public static string[] GetSelectedItems(this ListControl ctrl) {
			var q = from ListItem r in ctrl.Items
					where r.Selected
					select r.Value;
			var res = new List<string>();
			foreach (var val in q)
				res.Add(val);
			return res.ToArray();
		}


	}

}
