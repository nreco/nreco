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

namespace NReco.Operations {
	
	/// <summary>
	/// Composite chain operations. Just executes ordered list of another operations.
	/// </summary>
	public class Chain : IOperation<IDictionary<string,object>> {

		IOperation<IDictionary<string, object>>[] _Operations;

		public IOperation<IDictionary<string, object>>[] Operations {
			get { return _Operations; }
			set { _Operations = value; }
		}

		public Chain() { }

		public Chain(IOperation<IDictionary<string,object>>[] ops) {
			Operations = ops;
		}

		public void Execute(IDictionary<string,object> context) {
			for (int i=0; i<Operations.Length; i++)
				Operations[i].Execute(context);
		}

	}
}
