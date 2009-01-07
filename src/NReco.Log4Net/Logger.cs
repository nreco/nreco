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
using System.Text;

using NReco;
using NReco.Logging;

namespace NReco.Log4Net {
	
	/// <summary>
	/// Log4Net logger wrapper for NReco logging subsystem.
	/// </summary>
	public class Logger : IProvider<LogWrapper,NReco.Logging.ILog> {

		public NReco.Logging.ILog Provide(LogWrapper context) {
			log4net.ILog realLog = log4net.LogManager.GetLogger(context.ForAssembly,context.ForType);
			return new Log(realLog);
		}

		internal class Log : NReco.Logging.ILog {
			log4net.ILog realLog;

			internal Log(log4net.ILog log) {
				realLog = log;
			}

			protected string Format(object context) {
				return context.ToString();
			}

			public void Write(LogEvent e, string fmtMsg, params object[] args) {
				switch (e) {
					case LogEvent.Debug:
						realLog.DebugFormat(fmtMsg, args);
						break;
					case LogEvent.Info:
						realLog.InfoFormat(fmtMsg, args);
						break;
					case LogEvent.Warn:
						realLog.WarnFormat(fmtMsg, args);
						break;
					case LogEvent.Error:
						realLog.ErrorFormat(fmtMsg, args);
						break;
					case LogEvent.Fatal:
						realLog.FatalFormat(fmtMsg, args);
						break;
				}
				
			}
			public void Write(LogEvent e, object context) {
				Write(e, Format(context) );
			}

			public bool IsEnabledFor(LogEvent e) {
				switch (e) {
					case LogEvent.Debug: return realLog.IsDebugEnabled;
					case LogEvent.Info: return realLog.IsInfoEnabled;
					case LogEvent.Warn: return realLog.IsWarnEnabled;
					case LogEvent.Error: return realLog.IsErrorEnabled;
					case LogEvent.Fatal: return realLog.IsFatalEnabled;
				}
				return false;
			}

		}

	}
}
