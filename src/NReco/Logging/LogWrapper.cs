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
using System.Reflection;
using System.Text;

namespace NReco.Logging {
	
	/// <summary>
	/// Wrapper over real log instance.
	/// </summary>
	public class LogWrapper : ILog {
		internal ILog RealLog = null;
		Assembly _ForAssembly;
		Type _ForType;
		
		public Assembly ForAssembly {
			get { return _ForAssembly; }
		}
		
		public Type ForType {
			get { return _ForType; }
		}
		
		internal LogWrapper(Assembly a, Type t) {
			_ForAssembly = a;
			_ForType = t;
		}
		
		public void Info(string fmtMsg, params object[] args) {
			if (RealLog!=null)
				RealLog.Info(fmtMsg, args);
		}
		public void Info(string[] keys, object[] values) {
			if (RealLog != null)
				RealLog.Info(keys, values);
		}

		public void Error(string fmtMsg, params object[] args) {
			if (RealLog != null)
				RealLog.Error(fmtMsg, args);
		}
		public void Error(string[] keys, object[] values) {
			if (RealLog != null)
				RealLog.Error(keys, values);
		}

		public void Warn(string fmtMsg, params object[] args) {
			if (RealLog != null)
				RealLog.Warn(fmtMsg, args);			
		}
		public void Warn(string[] keys, object[] values) {
			if (RealLog != null)
				RealLog.Warn(keys, values);
		}

		public void Fatal(string fmtMsg, params object[] args) {
			if (RealLog != null)
				RealLog.Fatal(fmtMsg, args);			
		}
		public void Fatal(string[] keys, object[] values) {
			if (RealLog != null)
				RealLog.Fatal(keys, values);
		}

		public void Debug(string fmtMsg, params object[] args) {
			if (RealLog != null)
				RealLog.Debug(fmtMsg, args);
		}
		public void Debug(string[] keys, object[] values) {
			if (RealLog != null)
				RealLog.Debug(keys, values);
		}


	}
}
