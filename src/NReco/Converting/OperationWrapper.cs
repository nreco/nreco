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
using System.Text;

namespace NReco.Converting {
	
	/// <summary>
	/// Operation wrapper between generic and non-generic operation interfaces
	/// </summary>
	/// <typeparam name="Context">context type</typeparam>
	public class OperationWrapper<C1,C2> : IOperation<C2> {

		public IOperation<C1> UnderlyingOperation { get; set; }

		public OperationWrapper() { }

		public OperationWrapper(IOperation<C1> op) {
			UnderlyingOperation = op;
		}

		public void Execute(C2 context) {
			C1 c;
			if (!(context is C1) && context != null) {
				c = ConvertManager.ChangeType<C1>(context);
			}
			else {
				c = (C1)((object)context);
			}
			UnderlyingOperation.Execute( c );
		}

	}


}
