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
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace NReco.Composition {
	
	/// <summary>
	/// Throw exception operation.
	/// </summary>
	public class ThrowException<ContextT> : IOperation<ContextT> {

		public IProvider<ContextT, string> MessageProvider { get; set; }

		public ThrowException() { }

		public void Execute(ContextT context) {
			if (MessageProvider != null) {
				throw new Exception(MessageProvider.Provide(context));
			} else {
				throw new Exception();
			}
		}

	}

	/// <summary>
	/// Throw exception operation.
	/// </summary>
	public class ThrowException : ThrowException<object> {
		public ThrowException() { }
	}


}
