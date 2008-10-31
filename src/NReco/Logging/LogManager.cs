using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;

namespace NReco.Logging {
	
	public static class LogManager {
		
		static IProvider<Type,ILog> LogProvider;
		
		internal static ILog GetRealLogger(Assembly a, Type t) {
			return null;
		}
		
		public static ILog GetLogger(Type t) {
			return new LogWrapper(Assembly.GetCallingAssembly(), t);
		}
	
	}
}
