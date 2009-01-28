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
	/// Chain-oriented operation wrapper  
	/// </summary>
	public class ChainOperationCall : OperationCall, IOperation<IDictionary<string, object>> {
		
		IProvider<IDictionary<string,object>,bool> _RunCondition = null;

		public IProvider<IDictionary<string,object>,bool> RunCondition {
			get { return _RunCondition; }
			set { _RunCondition = value; }
		}

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
