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
using log4net;

namespace NReco.Log4Net {
	
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

			public void Debug(string fmtMsg, params object[] args) {
				realLog.DebugFormat(fmtMsg, args);
			}

			public void Info(string fmtMsg, params object[] args) {
				realLog.InfoFormat(fmtMsg, args);
			}

			public void Warn(string fmtMsg, params object[] args) {
				realLog.WarnFormat(fmtMsg, args);
			}

			public void Error(string fmtMsg, params object[] args) {
				realLog.ErrorFormat(fmtMsg, args);
			}

			public void Fatal(string fmtMsg, params object[] args) {
				realLog.FatalFormat(fmtMsg, args);
			}

		}

	}
}
