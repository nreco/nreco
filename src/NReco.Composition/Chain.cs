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
using NReco.Converting;

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

	public class ChainProvider : Chain, IProvider<object, object> {

		public IProvider<object,IDictionary<string, object>> ContextBuilder { get; set; }
		public string ResultKey { get; set; }

		public ChainProvider() {
			ResultKey = "result";
		}

		public object Provide(object context) {
			IDictionary<string,object> chainContext = null;
			if (ContextBuilder!=null) {
				chainContext = ContextBuilder.Provide(context);
			} else {
				if (context != null) {
					var conv = ConvertManager.FindConverter(context.GetType(), typeof(IDictionary<string, object>));
					if (conv == null)
						chainContext = SingleNameValueProvider.Instance.Provide(context);
					else
						chainContext = (IDictionary<string, object>)conv.Convert(context, typeof(IDictionary<string, object>));
				}
			}
			Execute(chainContext);
			return chainContext.ContainsKey(ResultKey) ? chainContext[ResultKey] : null;
		}

	}


}
