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
	/// Operation wrapper that can substitute context for underlying operation.  
	/// </summary>
	public class OperationCall : IOperation {
		IOperation _Operation;
		IProvider _ContextProvider = null;

		public IOperation Operation {
			get { return _Operation; }
			set { _Operation = value; }
		}

		public IProvider ContextProvider {
			get { return _ContextProvider; }
			set { _ContextProvider = value; }
		}

		public OperationCall() { }

		public OperationCall(IOperation baseOp) {
			Operation = baseOp;
		}

		public void Execute(object context) {
			object opContext = context;
			if (ContextProvider!=null)
				opContext = ContextProvider.Provide(opContext);
			Operation.Execute(opContext);
		}

	}

}
