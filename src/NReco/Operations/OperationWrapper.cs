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
using NReco.Converting;

namespace NReco.Operations {
	
	/// <summary>
	/// Operation wrapper between generic and non-generic operation interfaces
	/// </summary>
	/// <typeparam name="Context">context type</typeparam>
	public class OperationWrapper<ContextT> : IOperation {
		IOperation<ContextT> _UnderlyingOperation;

		public IOperation<ContextT> UnderlyingOperation {
			get { return _UnderlyingOperation; }
			set { _UnderlyingOperation = value; }
		}

		public OperationWrapper() { }

		public OperationWrapper(IOperation<ContextT> op) {
			UnderlyingOperation = op;
		}

		public void Execute(object context) {
			if (!(context is ContextT) && context!=null) {
				context = ConvertManager.ChangeType(context, typeof(ContextT));
			}
			UnderlyingOperation.Execute( (ContextT)context);
		}

	}


}
