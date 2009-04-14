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
	/// Composes name-value dictionary from pairs template.
	/// </summary>
	public class NameValueProvider : IProvider<object,IDictionary<string,object>> {

		public IDictionary<string, IProvider<object, object>> PairProviders { get; set; }

		public IDictionary<string, object> Provide(object context) {
			var dictionary = new Dictionary<string, object>();
			foreach (var entry in PairProviders)
				dictionary[entry.Key] = entry.Value.Provide(context);
			return dictionary;
		}

	}

	/// <summary>
	/// Composes name-value dictionary with only one pair which value is given context.
	/// </summary>
	public class SingleNameValueProvider : IProvider<object, IDictionary<string, object>> {

		public readonly static SingleNameValueProvider Instance = new SingleNameValueProvider();

		public string Key { get; set; }

		public SingleNameValueProvider() {
			Key = "arg";
		}

		public SingleNameValueProvider(string key) {
			Key = key;
		}

		public IDictionary<string, object> Provide(object context) {
			var res = new Dictionary<string, object>(1);
			res[Key] = context;
			return res;
		}

	}

}
