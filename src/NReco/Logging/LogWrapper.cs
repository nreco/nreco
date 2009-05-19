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
		
		public void Write(LogEvent e, string fmtMsg, params object[] args) {
			if (RealLog!=null)
				RealLog.Write(e, fmtMsg, args);
		}
		public void Write(LogEvent e, object context) {
			if (RealLog != null)
				RealLog.Write(e, context);
		}

		public bool IsEnabledFor(LogEvent e) {
			if (RealLog != null)
				return RealLog.IsEnabledFor(e);
			return false;
		}

	}
}
