#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2014 Vitaliy Fedorchenko
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
using System.Text;
using System.Configuration;
using System.Web;
using System.Web.UI;

using NReco.Converting;
using NReco.Logging;
using NI.Ioc;

namespace NReco.Application.Web {
	
	/// <summary>
	/// NReco web layer manager.
	/// </summary>
	public static class AppContext {

		static ILog log = LogManager.GetLogger(typeof(AppContext));

		static AppContext() {
		}

		static string HttpRoot {
			get {
				return ConfigurationManager.AppSettings["NReco.Application.Web.AppContext.HttpRoot"] as string;
			}
		}

		public static string BaseUrlPath {
			get {
				var httpRoot = HttpRoot;
				if (httpRoot != null)
					return VirtualPathUtility.AppendTrailingSlash((new Uri(httpRoot)).AbsolutePath);
				return VirtualPathUtility.AppendTrailingSlash( System.Web.HttpRuntime.AppDomainAppVirtualPath );
			}
		}

		public static string BaseUrl {
			get {
				var httpRoot = HttpRoot;
				if (httpRoot != null)
					return httpRoot;
				return HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) + BaseUrlPath;
			}
		}

		/// <summary>
		/// Get or set instance of IComponentFactory for current request
		/// </summary>
		public static IComponentFactory ComponentFactory {
			get { return HttpContext.Current.Items["NReco.Application.Web.ComponentFactory"] as IComponentFactory; }
			set { HttpContext.Current.Items["NReco.Application.Web.ComponentFactory"] = value; }
		}
		
		/// <summary>
		/// Make full URL
		/// </summary>
		/// <param name="url">partial URL part</param>
		/// <returns>full URL</returns>
		public static string MakeFullUrl(string url) {
			if (url.StartsWith("/")) {
				var baseUri = new Uri(BaseUrl);
				return baseUri.GetLeftPart(UriPartial.Authority) + url;
			} else {
				if (Uri.IsWellFormedUriString(url,UriKind.Absolute))
					return url;
			}
			return VirtualPathUtility.AppendTrailingSlash(BaseUrl) + url;
		}

		/// <summary>
		/// Application-wide event broker
		/// </summary>
		public static EventBroker EventBroker {
			get {
				if (!HttpContext.Current.Items.Contains("NReco.Application.Web.EventBroker")) {
					EventBroker evBroker = null;
					if (ComponentFactory != null) {
						evBroker = ComponentFactory.GetService(typeof(EventBroker)) as EventBroker;
					}
					if (evBroker == null)
						evBroker = new EventBroker();
					HttpContext.Current.Items["NReco.Application.Web.EventBroker"] = evBroker;
				}
				return HttpContext.Current.Items["NReco.Application.Web.EventBroker"] as EventBroker;
			}

		}


		public static string GetLabel(string label, string context) {
			if (!HttpContext.Current.Items.Contains("NReco.Application.Web.LabelGlobalResourceFilter") && ComponentFactory!=null) {
				HttpContext.Current.Items["NReco.Application.Web.LabelGlobalResourceFilter"] = ComponentFactory.GetService(
					typeof(LabelGlobalResourceFilter));
			}
			var globalResFilter = HttpContext.Current.Items["NReco.Application.Web.LabelGlobalResourceFilter"] as LabelGlobalResourceFilter;
			if (globalResFilter != null)
				return globalResFilter.GetLabel(label, context);
			return label;
		}

	}
}
