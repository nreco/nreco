#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2014 Vitaliy Fedorchenko
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

using NReco.Logging;

namespace NReco.Functions {

	/// <summary>
	/// Delegate call action
	/// </summary>
	public class CallAction {
		
		public Delegate Target { get; set; }

		public Func<IDictionary<string,object>, object>[] Arguments { get; set; }

		public string Result { get; set; }

		public CallAction(Delegate t, Func<IDictionary<string, object>, object>[] args, string result) {
			Target = t;
			Arguments = args;
			Result = result;
		}

		public virtual void Invoke(IDictionary<string, object> context) {
			// TODO align arguments with delegate parameter types
		}

	}

}
