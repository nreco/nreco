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
	public class OperationCall<C> : IOperation<C> {

		public IOperation<C> Operation { get; set; }

		public IProvider<C, C> ContextFilter { get; set; }

		public OperationCall() { }

		public OperationCall(IOperation<C> baseOp) {
			Operation = baseOp;
		}

		public void Execute(C context) {
			var opContext = context;
			if (ContextFilter!=null)
				opContext = ContextFilter.Provide(opContext);
			Operation.Execute(opContext);
		}

	}

	public class OperationCall : OperationCall<object> {
		public OperationCall() { }

		public OperationCall(IOperation<object> o) : base(o) { }
	}

}
