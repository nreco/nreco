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
		/// Returns current page context.
		/// </summary>
		/// <remarks>
		/// When current page is RoutePage this method returns context composed from route data.
		/// </remarks>
		public static IDictionary<string, object> GetPageContext(this Control ctrl) {
			if (ctrl.Page is RoutePage)
				return ((RoutePage)ctrl.Page).PageContext;
			return null;
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
			var routeContext = new RouteValueDictionary(context);
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
			if (context is IDictionary)
				return GetRouteUrl(ctrl, routeName, (IDictionary)context);
			return GetRouteUrl(ctrl, routeName, new ObjectDictionaryWrapper(context));
		}

		/// <summary>
		/// Returns control parents axis of specified type.
		/// </summary>
		/// <returns>control parents axis ordered from direct parent to control tree root</returns>
		public static IEnumerable<T> GetParents<T>(this Control ctrl) where T : Control {
			while (ctrl.Parent != null) {
				ctrl = ctrl.Parent;
				if (ctrl is T)
					yield return (T)ctrl;
			}
		}

		/// <summary>
		/// Returns control childres of specified type.
		/// </summary>
		/// <remarks>
		/// This method performs breadth-first search (that can avoid full subtree traversal for some cases)
		/// and doesn't uses much memory even for huge subtrees.
		/// </remarks>
		public static IEnumerable<T> GetChildren<T>(this Control ctrl) where T : Control {
			var q = new Queue<Control>();
			for (int i = 0; i < ctrl.Controls.Count; i++)
				q.Enqueue(ctrl.Controls[i]);
			while (q.Count>0) {
				var c = q.Dequeue();
				if (c is T)
					yield return (T)c;
				for (int i = 0; i < c.Controls.Count; i++)
					q.Enqueue(c.Controls[i]);
			}
		}



	}

}
