using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;

namespace NReco.Logging {
	
	public class LogWrapper : ILog {
		ILog RealLog = null;
		Assembly _ForAssembly;
		Type _ForType;
		
		public Assembly ForAssembly {
			get { return _ForAssembly; }
		}
		
		public Type ForType {
			get { return _ForType; }
		}
		
		public LogWrapper(Assembly a, Type t) {
			ForAssembly = a;
			ForType = t;
		}
		
		protected void EnsureRealLog() {
			if (RealLog==null)
				RealLog = LogManager.GetRealLogger(this);
		}
		
		public void Info(string fmtMsg, params object[] args) {
			EnsureRealLog();
			if (RealLog!=null)
				RealLog.Info(fmtMsg, args);
		}

		public void Error(string fmtMsg, params object[] args) {
			EnsureRealLog();
			if (RealLog != null)
				RealLog.Error(fmtMsg, args);
		}

		public void Warn(string fmtMsg, params object[] args) {
			EnsureRealLog();
			if (RealLog != null)
				RealLog.Warn(fmtMsg, args);			
		}

		public void Fatal(string fmtMsg, params object[] args) {
			EnsureRealLog();
			if (RealLog != null)
				RealLog.Fatal(fmtMsg, args);			
		}
	}
}
