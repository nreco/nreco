#region License
/*
 * NReco library (http://code.google.com/p/nreco/)
 * Copyright 2008 Vitaliy Fedorchenko
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

namespace NReco.Web.Site {
	
	public static class Extensions {

		public static IDictionary<string, object> GetPageContext(this Control ctrl) {
			if (ctrl.Page is RoutePage)
				return ((RoutePage)ctrl.Page).PageContext;
			return null;
		}

		public static string GetRouteUrl(this Control ctrl, string routeName, IDictionary context) {
			var cntx = ConvertManager.ChangeType<IDictionary<string, object>>(context);
			return GetRouteUrl(ctrl, routeName, cntx);
		}

		public static string GetRouteUrl(this Control ctrl, string routeName, IDictionary<string,object> context) {
			var routeContext = new RouteValueDictionary(context);
			if (routeName != null) {
				var vpd = RouteTable.Routes.GetVirtualPath(null, routeName, routeContext);
				int paramStart = vpd.VirtualPath.IndexOf('?');
				return paramStart >= 0 ? vpd.VirtualPath.Substring(0, paramStart) : vpd.VirtualPath;
			}
			return null;
		}

	}

}
