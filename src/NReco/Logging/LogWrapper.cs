using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;

namespace NReco.Logging {
	
	public class LogWrapper : ILog {
		ILog RealLog = null;
		Assembly ForAssembly;
		Type ForType;
	
		
		public LogWrapper(Assembly a, Type t) {
			ForAssembly = a;
			ForType = t;
		}
		
		protected void EnsureRealLog() {
			if (RealLog==null)
				RealLog = LogManager.GetRealLogger(ForAssembly, ForType);
		}
		
		public void Info(string fmtMsg, params object[] args) {
			EnsureRealLog();
			RealLog.Info(fmtMsg, args);
		}

		public void Error(string fmtMsg, params object[] args) {
			EnsureRealLog();
			RealLog.Error(fmtMsg, args);
		}

		public void Warn(string fmtMsg, params object[] args) {
			EnsureRealLog();
			RealLog.Warn(fmtMsg, args);			
		}

		public void Fatal(string fmtMsg, params object[] args) {
			EnsureRealLog();
			RealLog.Fatal(fmtMsg, args);			
		}
	}
}
