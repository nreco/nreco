using System;
using System.Collections.Generic;
using System.Text;
using System.Web;

namespace NReco.Web {
	
	/// <summary>
	/// NReco web layer web context manager.
	/// </summary>
	public static class WebManager {

		public static readonly string ServiceProviderContextKey = "__service_provider";

		static WebManager() {
		}

		public static IProvider ServiceProvider {
			get { return HttpContext.Current.Items[ServiceProviderContextKey] as IProvider; }
			set { HttpContext.Current.Items[ServiceProviderContextKey] = value; }
		}

		public static object GetService(string serviceName) {
			return ServiceProvider.Provide(serviceName);
		}

		public static object GetService(Type serviceType) {
			return ServiceProvider.Provide(serviceType);
		}


	}
}
