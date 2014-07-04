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
using System.Linq;
using System.Text;
using System.Configuration;
using System.Web;
using System.IO;

using NReco;
using NReco.Logging;
using NI.Ioc;

namespace NReco.Application.Web {

	public class AppContextModule : System.Web.IHttpModule {
		static ILog log = LogManager.GetLogger(typeof(AppContextModule));

		protected HttpApplication Context;
		protected FileSystemWatcher AppFileWatcher;

		public static string ContainerSectionName {
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
			if (AppFileWatcher != null) {
				AppFileWatcher.EnableRaisingEvents = false;
				AppFileWatcher.Dispose();
				AppFileWatcher = null;
			}
		}

		public void Init(HttpApplication context) {
			Context = context;
			Context.BeginRequest += OnBeginRequest;
			Context.EndRequest += OnEndRequest;

			AppFileWatcher = new FileSystemWatcher(HttpRuntime.AppDomainAppPath);
			AppFileWatcher.IncludeSubdirectories = true;
			AppFileWatcher.NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.FileName;
			AppFileWatcher.Changed += new FileSystemEventHandler(OnAppFileChanged);
			AppFileWatcher.Deleted += new FileSystemEventHandler(OnAppFileChanged);
			AppFileWatcher.EnableRaisingEvents = true;
		}

		protected void OnAppFileChanged(object sender, FileSystemEventArgs e) {
			if (!File.Exists(e.FullPath))
				return;

			if (Context.Application[ContainerConfigKey] is NReco.Application.Ioc.XmlComponentConfiguration) {
				var xmlConfig = (NReco.Application.Ioc.XmlComponentConfiguration)Context.Application[ContainerConfigKey];
				var appFile = e.FullPath.Replace(Path.AltDirectorySeparatorChar, Path.DirectorySeparatorChar);
				if (xmlConfig.SourceFileNames.Contains(appFile)) {
					log.Write(LogEvent.Info, "Application configuration file changed: {0}", appFile);
					System.Web.HttpRuntime.UnloadAppDomain(); // reload application with new configuration
				}
			}

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
