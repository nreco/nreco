using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;

namespace NReco.Logging {
	
	public static class LogManager {
		
		static IProvider<LogWrapper,ILog> LogProvider = null;
		
		static LogManager() {
		}
		
		internal static ILog GetRealLogger(LogWrapper logWrapper) {
			return LogProvider!=null ? LogProvider.Provide(logWrapper) : null;
		}
		
		public static ILog GetLogger(Type t) {
			return new LogWrapper(Assembly.GetCallingAssembly(), t);
		}
	
	}
}
