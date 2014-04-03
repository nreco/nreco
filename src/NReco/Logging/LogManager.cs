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
		static ILogFactory RealLogFactory = null;

		static LogManager() {
		}
		
		public static ILog GetLogger(Type t) {
			if (!RegisteredLogs.ContainsKey(t)) {
				RegisteredLogs[t] = new LogWrapper(Assembly.GetCallingAssembly(), t);
				if (RealLogFactory != null)
					RegisteredLogs[t].RealLog = RealLogFactory.GetLog(RegisteredLogs[t]);
			}
			return RegisteredLogs[t];
		}

		public static void Configure(ILogFactory logFactory) {
			RealLogFactory = logFactory;
			foreach (KeyValuePair<Type,LogWrapper> logEntry in RegisteredLogs) {
				ILog realLog = RealLogFactory != null ? logFactory.GetLog(logEntry.Value) : null;
				logEntry.Value.RealLog = realLog;
			}
		}
	
	}
}
