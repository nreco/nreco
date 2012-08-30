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
using System.Web.Routing;
using System.Web.SessionState;

namespace NReco.Web.Site {
	
	public class RoutingHttpHandler : UrlRoutingHandler, IRequiresSessionState {

		protected override void VerifyAndProcessRequest(IHttpHandler httpHandler, HttpContextBase httpContext) {
			if (httpHandler == null) {
				throw new ArgumentNullException("httpHandler");
			}
			var origHttpHandler = httpContext.Handler;
			try {
				httpContext.Handler = httpHandler;
				httpHandler.ProcessRequest(HttpContext.Current);
			} finally {
				httpContext.Handler = origHttpHandler;
			}
		}
	}

}
