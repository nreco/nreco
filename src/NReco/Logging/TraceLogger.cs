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
			return new Log(this, context.ForType.FullName);
		}

		protected bool TraceDebugInfo {
			get { return traceDebugInfoSwitch.Enabled; }
		}

		internal class Log : ILog {
			TraceLogger Logger;
			string Name;

			public Log(TraceLogger trLogger, string logName) {
				Logger = trLogger;
				Name = logName;
			}

			protected string JoinKeys(string[] keys) {
				StringBuilder sb = new StringBuilder();
				for (int i=0; i<keys.Length; i++) {
					sb.Append('[');
					sb.Append(keys[i]);
					sb.Append("={0}]");
				}
				return sb.ToString();
			}

			public void Debug(string fmtMsg, params object[] args) {
				if (Logger.TraceDebugInfo)
					System.Diagnostics.Trace.TraceInformation( String.Format( AddInfo(fmtMsg), args) );
			}
			public void Debug(string[] keys, object[] values) {
				if (keys.Length!=keys.Length)
					throw new ArgumentException();
				Debug(JoinKeys(keys), values);
			}

			public void Info(string fmtMsg, params object[] args) {
				Trace.TraceInformation( AddInfo(fmtMsg), args);
			}
			public void Info(string[] keys, object[] values) {
				if (keys.Length!=keys.Length)
					throw new ArgumentException();
				Info(JoinKeys(keys), values);
			}

			public void Warn(string fmtMsg, params object[] args) {
				Trace.TraceWarning( AddInfo(fmtMsg), args);
			}
			public void Warn(string[] keys, object[] values) {
				if (keys.Length!=keys.Length)
					throw new ArgumentException();
				Warn(JoinKeys(keys), values);
			}

			public void Error(string fmtMsg, params object[] args) {
				Trace.TraceError( AddInfo(fmtMsg), args);
			}
			public void Error(string[] keys, object[] values) {
				if (keys.Length!=keys.Length)
					throw new ArgumentException();
				Error(JoinKeys(keys), values);
			}

			public void Fatal(string fmtMsg, params object[] args) {
				Trace.TraceError( AddInfo(fmtMsg), args);
			}
			public void Fatal(string[] keys, object[] values) {
				if (keys.Length!=keys.Length)
					throw new ArgumentException();
				Fatal(JoinKeys(keys), values);
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
					sb.Append('\t');
				}
				sb.Append(msg);
				return sb.ToString();
			}

		}

	}
}
