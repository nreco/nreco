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

namespace NReco.Composition {

	/// <summary>
	/// Chain-oriented operation wrapper  
	/// </summary>
	public class ChainOperationCall : OperationCall, IOperation<IDictionary<string, object>> {
		
		/// <summary>
		/// Get or set call condition (optional).
		/// </summary>
		public IProvider<IDictionary<string, object>, bool> RunCondition { get; set; }

		public ChainOperationCall() { }

		public ChainOperationCall(IOperation<object> op) : base(op) { }

		public void Execute(IDictionary<string, object> context) {
			if (RunCondition!=null)
				if (!RunCondition.Provide(context))
					return;
			Execute( (object)context );
		}

	}

}
