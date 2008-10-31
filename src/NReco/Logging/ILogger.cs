using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Logging {
	
	/// <summary>
	/// Simple interface to logger used by NReco core components.
	/// </summary>
	/// <remarks>
	/// It's recommended to use log4net for logging with NReco.
	/// This interface incapsulates NReco logging needs; it just breakes direct dependency from log4net.
	/// </remarks>
	public interface ILog {
		void Info(string fmtMsg, params object[] args);
		void Warn(string fmtMsg, params object[] args);
		void Error(string fmtMsg, params object[] args);
		void Fatal(string fmtMsg, params object[] args);
	}
}
