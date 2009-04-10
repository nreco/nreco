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

namespace NReco.Composition {
	
	/// <summary>
	/// Generic chain (sequence) of another operations.
	/// </summary>
	public class Chain<ContextT> : IOperation<ContextT> {

		IOperation<ContextT>[] _Operations;

		/// <summary>
		/// Get or set chain operations list.
		/// </summary>
		public IOperation<ContextT>[] Operations {
			get { return _Operations; }
			set { _Operations = value; }
		}

		public Chain() { }

		public Chain(IOperation<ContextT>[] ops) {
			Operations = ops;
		}

		public Chain(IList<IOperation<ContextT>> ops) {
			Operations = new IOperation<ContextT>[ops.Count];
			ops.CopyTo(Operations, 0);
		}


		public void Execute(ContextT context) {
			for (int i=0; i<Operations.Length; i++)
				Operations[i].Execute(context);
		}

	}

	/// <summary>
	/// Operations chain
	/// </summary>
	public class Chain : Chain<IDictionary<string, object>> {

		public Chain() { }

		public Chain(IOperation<IDictionary<string, object>>[] ops) {
			Operations = ops;
		}
	}


}
