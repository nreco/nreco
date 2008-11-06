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
	/// Simple interface to logger used by NReco core components.
	/// </summary>
	/// <remarks>
	/// Reason why NReco has additional abstraction from standard .NET tracing schema is flexibility.
	/// In particular alternative logging framework (log4net) may be used for logging NReco.
	/// </remarks>
	public interface ILog {
		void Debug(string fmtMsg, params object[] args);
		void Debug(string[] keys, object[] values);
		
		void Info(string fmtMsg, params object[] args);
		void Info(string[] keys, object[] values);

		void Warn(string fmtMsg, params object[] args);
		void Warn(string[] keys, object[] values);

		void Error(string fmtMsg, params object[] args);
		void Error(string[] keys, object[] values);

		void Fatal(string fmtMsg, params object[] args);
		void Fatal(string[] keys, object[] values);
	}
}
