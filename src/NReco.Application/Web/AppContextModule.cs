using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using System.Web;

using NReco;
using NReco.Logging;
using NI.Ioc;

namespace NReco.Application.Web {

	public class AppContextModule : System.Web.IHttpModule {
		static ILog log = LogManager.GetLogger(typeof(AppContextModule));

		protected HttpApplication Context;

		public string ContainerSectionName {
			get {
				var secName = ConfigurationManager.AppSettings["NReco.Application.ContainerSectionName"];
				if (secName == null)
					secName = "containerConfiguration"; // default section name
				return secName;
			}
		}

		const string ContainerConfigKey = "NReco.Application.Web.ContainerModule.ContainerConfiguration";
		static object configSyncRoot = new object();

		public IComponentFactoryConfiguration ContainerConfiguration {
			get {
				if (Context.Application[ContainerConfigKey] == null) {
					lock (configSyncRoot) {
						// one more check inside monitor
						if (Context.Application[ContainerConfigKey] == null) {
							Context.Application[ContainerConfigKey] = ConfigurationManager.GetSection(ContainerSectionName);
						}
					}
				}
				return Context.Application[ContainerConfigKey] as IComponentFactoryConfiguration;
			}

		}



		public void Dispose() {
		}

		public void Init(HttpApplication context) {
			Context = context;
			Context.BeginRequest += OnBeginRequest;
			Context.EndRequest += OnEndRequest;
		}

		protected virtual void OnBeginRequest(object sender, EventArgs e) {
			AppContext.ComponentFactory = new NReco.Application.Ioc.ComponentFactory(ContainerConfiguration);
		}

		protected virtual void OnEndRequest(object sender, EventArgs e) {
			if (AppContext.ComponentFactory is IDisposable) {
				((IDisposable)AppContext.ComponentFactory).Dispose();
				AppContext.ComponentFactory = null;
			}
		}

	}
}
