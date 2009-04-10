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
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace NReco.Operations {
	
	/// <summary>
	/// Each list operation. Just executes specified operation over list items.
	/// </summary>
	public class Each<ContextT> : IOperation<ContextT> {

		/// <summary>
		/// Enumerable items provider. Optional (if it is not defined context is suggested to be enumerable)
		/// </summary>
		public IProvider<ContextT, IEnumerable> ItemsProvider { get; set; }

		public IOperation<EachContext<ContextT>> ItemOperation { get; set; }

		public Each() { }

		public void Execute(ContextT context) {
			var items = ItemsProvider!=null ? ItemsProvider.Provide(context) : (IEnumerable)context;
			var itemContext = new EachContext<ContextT>() { ParentContext = context };
			int index = 0;
			foreach (var itemObj in items) {
				itemContext.Index = index++;
				itemContext.Item = itemObj;
				ItemOperation.Execute(itemContext);
			}
		}

	}

	public class EachContext<T> : Context {
		public T ParentContext { get; set; }
		public object Item { get; set; }
		public int Index { get; set; }
	}

	/// <summary>
	/// Abstract each operation
	/// </summary>
	public class Each : Each<object> {

		public Each() { }

	}


}
