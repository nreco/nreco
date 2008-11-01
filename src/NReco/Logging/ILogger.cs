using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Logging {
	
	/// <summary>
	/// Simple interface to logger used by NReco core components.
	/// </summary>
	/// <remarks>
	/// Reason why NReco has additional abstraction from standard .NET tracing schema is flexibility.
	/// In particular alternative logging framework (log4net) may be used for logging NReco.
	/// </remarks>
	public interface ILog {
		void Debug(string fmtMsg, params object[] args);
		void Info(string fmtMsg, params object[] args);
		void Warn(string fmtMsg, params object[] args);
		void Error(string fmtMsg, params object[] args);
		void Fatal(string fmtMsg, params object[] args);
	}
}
