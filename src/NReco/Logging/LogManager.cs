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

		static LogManager() {
		}
		
		public static ILog GetLogger(Type t) {
			if (!RegisteredLogs.ContainsKey(t)) {
				RegisteredLogs[t] = new LogWrapper(Assembly.GetCallingAssembly(), t);
				if (RealLogProvider!=null)
					RegisteredLogs[t].RealLog = RealLogProvider.Provide(RegisteredLogs[t]);
			}
			return RegisteredLogs[t];
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
