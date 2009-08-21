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
using System.Web.Compilation;

namespace NReco.Web.Site
{
    public class AxdRouteHandler : IRouteHandler
    {
        public Type HandlerType { get; set; }

        public AxdRouteHandler(Type handlerType) {
            this.HandlerType = handlerType;
		}

        public AxdRouteHandler() {
        }

        public IHttpHandler GetHttpHandler(RequestContext requestContext) {
            var handler = (IHttpHandler)Activator.CreateInstance(HandlerType);
            if (handler is IRouteAware)
                ((IRouteAware)handler).RoutingRequestContext = requestContext;
            return handler;
        }
    }
}
