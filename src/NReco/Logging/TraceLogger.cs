#region License
/*
 * NReco library (http://code.google.com/p/nreco/)
 * Copyright 2008 Vitaliy Fedorchenko
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
	/// Default .NET trace logger implementation.
	/// </summary>
	public class TraceLogger : IProvider<LogWrapper,ILog> {
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

		public ILog Provide(LogWrapper context) {
			return new TraceLog(this, context.ForType.FullName);
		}

		protected bool TraceDebugInfo {
			get { return traceDebugInfoSwitch.Enabled; }
		}

		internal class TraceLog : ILog {
			TraceLogger Logger;
			string Name;

			public TraceLog(TraceLogger trLogger, string logName) {
				Logger = trLogger;
				Name = logName;
			}

			protected string JoinKeys(string[] keys) {
				StringBuilder sb = new StringBuilder();
				for (int i=0; i<keys.Length; i++) {
					sb.Append('[');
					sb.Append(keys[i]);
					sb.Append("={");
					sb.Append(i);
					sb.Append("}]");
				}
				return sb.ToString();
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
			public void Write(LogEvent e, string[] keys, object[] values) {
				Write(e, JoinKeys(keys), values);
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
