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

namespace NReco {
	
	/// <summary>
	/// Simple name -> value context.
	/// </summary>
	[Serializable]
	public class NameValueContext : Context, IDictionary<string,object> {
		IDictionary<string,object> NameValueMap;

		public NameValueContext() {
			NameValueMap = new Dictionary<string,object>();
		}

		public NameValueContext(IDictionary<string,object> map) {
			NameValueMap = map;
		}

		public override string ToString() {
			StringBuilder sb = new StringBuilder();
			sb.Append('{');
			bool first = true;
			foreach (string key in NameValueMap.Keys) {
				if (!first) sb.Append(',');
				sb.Append(key);
				sb.Append(':');
				sb.Append(NameValueMap[key]);
				first = false;
			}
			sb.Append('}');
			return sb.ToString();
		}

		public void Add(string key, object value) {
			NameValueMap.Add(key,value);
		}
		public bool ContainsKey(string key) {
			return NameValueMap.ContainsKey(key);
		}
		public ICollection<string> Keys {
			get { return NameValueMap.Keys; }
		}
		public bool Remove(string key) {
			return NameValueMap.Remove(key);
		}
		public bool TryGetValue(string key, out object value) {
			return NameValueMap.TryGetValue(key,out value);
		}
		public ICollection<object> Values {
			get { return NameValueMap.Values; }
		}

		public object this[string key] {
			get { return NameValueMap[key]; }
			set { NameValueMap[key] = value; }
		}

		public void Add(KeyValuePair<string, object> item) {
			NameValueMap.Add(item);
		}

		public void Clear() {
			NameValueMap.Clear();
		}

		public bool Contains(KeyValuePair<string, object> item) {
			return NameValueMap.Contains(item);
		}

		public void CopyTo(KeyValuePair<string, object>[] array, int arrayIndex) {
			NameValueMap.CopyTo(array, arrayIndex);
		}

		public int Count {
			get { return NameValueMap.Count; }
		}

		public bool IsReadOnly {
			get { return NameValueMap.IsReadOnly; }
		}

		public bool Remove(KeyValuePair<string, object> item) {
			return NameValueMap.Remove(item);
		}

		public IEnumerator<KeyValuePair<string, object>> GetEnumerator() {
			return NameValueMap.GetEnumerator();
		}

		IEnumerator IEnumerable.GetEnumerator() {
			return ((IEnumerable)NameValueMap).GetEnumerator();
		}

	}
}
