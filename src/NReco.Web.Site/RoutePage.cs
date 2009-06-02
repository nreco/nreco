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
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.Routing;

namespace NReco.Web.Site {
	
	/// <summary>
	/// Route-aware page.
	/// </summary>
	public class RoutePage : Page, IRouteAware {
		public RoutePage() { }

		public RequestContext RoutingRequestContext { get; set; }

		IDictionary<string, object> _RouteContext = null;

		public IDictionary<string,object> RouteContext {
			get {
				if (_RouteContext==null) {
					_RouteContext = new Dictionary<string, object>();
					if (RoutingRequestContext != null) {
						foreach (var entry in RoutingRequestContext.RouteData.Values)
							_RouteContext[entry.Key] = entry.Value;
						if (RoutingRequestContext.RouteData.DataTokens!=null)
							foreach (var entry in RoutingRequestContext.RouteData.DataTokens)
								_RouteContext[entry.Key] = entry.Value;
					}
				}
				return _RouteContext;
			}
		}

	}
}
