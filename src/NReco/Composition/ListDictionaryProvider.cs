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
using System.Collections;
using System.Text;

namespace NReco.Composition {

	/// <summary>
	/// Composes dictionary using entries from the list.
	/// </summary>
	public class ListDictionaryProvider : IProvider<IEnumerable, IDictionary> {

		/// <summary>
		/// Get or set dictionary key provider
		/// </summary>
		public IProvider<object, object> KeyProvider { get; set; }

		/// <summary>
		/// Get or set dictionary value provider
		/// </summary>
		public IProvider<object, object> ValueProvider { get; set; }

		public ListDictionaryProvider() {
		}

		public ListDictionaryProvider(IProvider<object,object> keyPrv, IProvider<object,object> valuePrv) {
			KeyProvider = keyPrv;
			ValueProvider = valuePrv;
		}

		public IDictionary Provide(IEnumerable list) {
			var res = new Hashtable();
			foreach (object o in list) {
				var key = KeyProvider.Provide(o);
				var value = ValueProvider.Provide(o);
				if (key != null)
					res[key] = value;
			}
			return res;
		}

	}

}
