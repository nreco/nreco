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
using System.Diagnostics;
using System.Text;
using System.Threading;

namespace NReco.Logging {
	
	/// <summary>
	/// Default .NET trace log factory implementation.
	/// </summary>
	public class TraceLogFactory : ILogFactory {
		bool _IncludeIdentityName = true;
		bool _IncludeTimestamp = true;
		string _IdentityNameFormat = "[identity={0}]";
		string _TimestampFormat = "{0:u}";
		static BooleanSwitch traceDebugInfoSwitch = new BooleanSwitch("NReco.Logging.TraceLogger.DebugInfo",String.Empty,"0");

		public string IdentityNameFormat {
			get { return _IdentityNameFormat; }
			set { _IdentityNameFormat = value; }
		}

		public string TimestampFormat {
			get { return _TimestampFormat; }
			set { _TimestampFormat = value; }
		}

		public bool IncludeTimestamp {
			get { return _IncludeTimestamp; }
			set { _IncludeTimestamp = value; }
		}

		public bool IncludeIdentityName {
			get { return _IncludeIdentityName; }
			set { _IncludeIdentityName = value; }
		}

		public TraceLogFactory() {

		}

		public TraceLogFactory(bool includeTime, bool includeIdentity) {
			IncludeTimestamp = includeTime;
			IncludeIdentityName = includeIdentity;
		}

		public ILog GetLog(LogWrapper context) {
			return new TraceLog(this, context.ForType.FullName);
		}

		protected bool TraceDebugInfo {
			get { return traceDebugInfoSwitch.Enabled; }
		}

		internal class TraceLog : ILog {
			TraceLogFactory Logger;
			string Name;

			public TraceLog(TraceLogFactory trLogger, string logName) {
				Logger = trLogger;
				Name = logName;
			}

			protected string Format(object context) {
				return context.ToString();
			}

			public void Write(LogEvent e, string fmtMsg, params object[] args) {
				switch (e) {
					case LogEvent.Debug:
						if (Logger.TraceDebugInfo)
							System.Diagnostics.Trace.TraceInformation( String.Format( AddInfo(fmtMsg), args) );
						break;
					case LogEvent.Info:
						Trace.TraceInformation(AddInfo(fmtMsg), args);
						break;
					case LogEvent.Warn:
						Trace.TraceWarning(AddInfo(fmtMsg), args);
						break;
					case LogEvent.Error:
						Trace.TraceError(AddInfo(fmtMsg), args);
						break;
					case LogEvent.Fatal:
						Trace.TraceError(AddInfo(fmtMsg), args);
						break;
				}
			}
			public void Write(LogEvent e, object context) {
				Write(e, Format(context).Replace("{","{{").Replace("}","}}") );
			}

			public bool IsEnabledFor(LogEvent e) {
				if (e==LogEvent.Debug && !Logger.TraceDebugInfo)
					return false;
				return true;
			}

			protected string AddInfo(string msg) {
				StringBuilder sb = new StringBuilder();
				sb.Append(Name);
				sb.Append('\t');
				if (Logger.IncludeTimestamp) {
					sb.AppendFormat( Logger.TimestampFormat, DateTime.Now );
					sb.Append('\t');
				}
				if (Logger.IncludeIdentityName) {
					sb.AppendFormat( Logger.IdentityNameFormat, Thread.CurrentPrincipal.Identity.Name );
				}
				sb.Append(msg);
				return sb.ToString();
			}

		}

	}
}
