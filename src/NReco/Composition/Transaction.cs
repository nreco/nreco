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
	/// Transaction operation wrapper. 
	/// </summary>
	/// <remarks>This wrapper defines 3 slots that are typical for transaction logic: Begin,Commit,Abort</remarks>
	/// <typeparam name="C">Operation context type</typeparam>
	public class Transaction<C> : IOperation<C> {

		public IOperation<C> UnderlyingOperation { get; set; }

		public IOperation<C> Begin { get; set; }
		public IOperation<C> Commit { get; set; }
		public IOperation<C> Abort { get; set; }

		public Transaction() { }

		public void Execute(C context) {
			if (Begin!=null)
				Begin.Execute(context);
			try {
				UnderlyingOperation.Execute(context);
				if (Commit!=null)
					Commit.Execute(context);
			} catch (Exception ex) {
				if (Abort!=null)
					Abort.Execute(context);
				throw new Exception(ex.Message, ex);
			}
		}

	}

	public class Transaction : Transaction<object> {
		public Transaction() { }
	}

}
