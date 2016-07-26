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
using System.Reflection;
using System.Text;

namespace NReco.Logging {
	
	/// <summary>
	/// LogManager defines static methods used for obtaining log instance.
	/// </summary>
	public static class LogManager {
		static IDictionary<Type,LogWrapper> RegisteredLogs = new Dictionary<Type,LogWrapper>();
		static IProvider<LogWrapper,ILog> RealLogProvider = null;
		
		private static Object getLock = new Object();

		static LogManager() {
		}
		
		public static ILog GetLogger(Type t) {
			lock (getLock) {
				if (!RegisteredLogs.ContainsKey(t)) {
					RegisteredLogs[t] = new LogWrapper(Assembly.GetCallingAssembly(), t);
					if (RealLogProvider!=null)
						RegisteredLogs[t].RealLog = RealLogProvider.Provide(RegisteredLogs[t]);
				}
				return RegisteredLogs[t];
			}
		}

		public static void Configure(IProvider<LogWrapper,ILog> logProvider) {
			RealLogProvider = logProvider;
			foreach (KeyValuePair<Type,LogWrapper> logEntry in RegisteredLogs) {
				ILog realLog = logProvider!=null ? logProvider.Provide(logEntry.Value) : null;
				logEntry.Value.RealLog = realLog;
			}
		}
	
	}
}
