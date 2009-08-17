#region License
/*
 * NReco library (http://code.google.com/p/nreco/)
 * Copyright 2008, 2009 Vitaliy Fedorchenko
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
using System.Text.RegularExpressions;

namespace NReco.Transform.Tool {
	
	public class ConsoleTraceListener : System.Diagnostics.ConsoleTraceListener {
		static Regex regex = new Regex("[:] [0-9]+ [:]", RegexOptions.Singleline);

		public ConsoleTraceListener() {
		}

		public override void Write(string message) {
			if (message.IndexOf(": 0 :") >= 0)
				return;
			base.Write(message);
		}
		public override void WriteLine(string message) {
			message = message.Replace("NReco.Transform.", "").Replace("\t", " ");
			base.WriteLine(message);
		}
	}

}
