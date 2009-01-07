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

namespace NReco.Logging {
	
	/// <summary>
	/// Simple interface for logging used by NReco core components.
	/// </summary>
	/// <remarks>
	/// Reason why NReco has additional abstraction from standard .NET tracing schema is flexibility.
	/// In particular alternative logging framework (log4net) may be used for logging NReco.
	/// </remarks>
	public interface ILog {
		
		/// <summary>
		/// Logs formatted message
		/// </summary>
		/// <param name="fmtMsg">format string</param>
		/// <param name="args">arguments</param>
		void Write(LogEvent logEvent, string fmtMsg, params object[] args);
		
		/// <summary>
		/// Logs debug event as name-value pairs
		/// </summary>
		/// <param name="keys">names</param>
		/// <param name="values">values</param>
		void Write(LogEvent logEvent, object context);
		
		/// <summary>
		/// Checks if debug events are enabled for this log
		/// </summary>
		bool IsEnabledFor(LogEvent logEvent);

	}
}
