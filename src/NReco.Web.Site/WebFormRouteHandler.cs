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
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Routing;
using System.Web.Compilation;

namespace NReco.Web.Site {

	/// <summary>
	/// Route handler based on route-aware HTTP request handler.
	/// </summary>
	public class WebFormRouteHandler<T> : IRouteHandler where T : IHttpHandler, new() {
		public string VirtualPath { get; set; }

		public WebFormRouteHandler(string virtualPath) {
			this.VirtualPath = virtualPath;
		}

		public IHttpHandler GetHttpHandler(RequestContext requestContext) {
			var handler = (IHttpHandler)BuildManager.CreateInstanceFromVirtualPath(VirtualPath, typeof(T));
			if (handler is IRouteAware)
				((IRouteAware)handler).RouteContext = requestContext;
			return handler;
		}

	}

}
