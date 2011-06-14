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
using System.Collections;
using System.Text;
using NReco.Converting;

namespace NReco.Collections {
	
	[Serializable]
	public class DictionaryGenericWrapper<TKey,TValue> : IDictionary<TKey,TValue>  {
		IDictionary Map;

		public DictionaryGenericWrapper(IDictionary map) {
			this.Map = map;
		}


		#region IDictionary<TKey,TValue> Members

		public void Add(TKey key, TValue value) {
			Map[key] = value;
		}

		public bool ContainsKey(TKey key) {
			return Map.Contains(key);
		}

		public ICollection<TKey> Keys {
			get {
				TKey[] list = new TKey[Map.Keys.Count];
				Map.Keys.CopyTo(list, 0);
				return list;
			}
		}

		public bool Remove(TKey key) {
			if (Map.Contains(key)) {
				Map.Remove(key);
				return true;
			}
			return false;
		}

		public bool TryGetValue(TKey key, out TValue value) {
			value = default(TValue);
			if (Map.Contains(key)) {
				value = (TValue)Map[key];
				return true;
			}
			return false;
		}

		public ICollection<TValue> Values {
			get {
				TValue[] list = new TValue[Map.Values.Count];
				Map.Values.CopyTo(list, 0);
				return list;
			}
		}

		public TValue this[TKey key] {
			get {
				if (Map[key] != null && !(Map[key] is TValue))
					return ConvertManager.ChangeType<TValue>(Map[key]);
				return (TValue)Map[key];
			}
			set {
				Map[key] = value;
			}
		}

		#endregion

		#region ICollection<KeyValuePair<TKey,TValue>> Members

		public void Add(KeyValuePair<TKey, TValue> item) {
			Map.Add(item.Key, item.Value);
		}

		public void Clear() {
			Map.Clear();
		}

		public bool Contains(KeyValuePair<TKey, TValue> item) {
			if (Map[item.Key] == null)
				return item.Value == null;
			return Map[item.Key].Equals( item.Value );
		}

		public void CopyTo(KeyValuePair<TKey, TValue>[] array, int arrayIndex) {
			throw new NotImplementedException();
		}

		public int Count {
			get { return Map.Count; }
		}

		public bool IsReadOnly {
			get { return Map.IsReadOnly; }
		}

		public bool Remove(KeyValuePair<TKey, TValue> item) {
			if (Contains(item)) {
				Map.Remove(item.Key);
				return true;
			}
			return false;
		}

		#endregion

		#region IEnumerable<KeyValuePair<TKey,TValue>> Members

		public IEnumerator<KeyValuePair<TKey, TValue>> GetEnumerator() {
			return new DictionaryEnumeratorWrapper<TKey,TValue>(Map.GetEnumerator());
		}

		#endregion

		#region IEnumerable Members

		IEnumerator IEnumerable.GetEnumerator() {
			return GetEnumerator();
		}

		#endregion


		private sealed class DictionaryEnumeratorWrapper<TK, TV> : IEnumerator<KeyValuePair<TK, TV>>, IEnumerator {
			IDictionaryEnumerator Enumerator;

			public DictionaryEnumeratorWrapper(IDictionaryEnumerator enumerator) {
				this.Enumerator = enumerator;
			}

			public void Reset() {
				Enumerator.Reset();
			}

			public bool MoveNext() {
				return Enumerator.MoveNext();
			}

			public KeyValuePair<TK, TV> Current {
				get {
					var currentPair = Enumerator.Entry;
					var val = currentPair.Value!=null && !(currentPair is TV) ? ConvertManager.ChangeType<TV>(currentPair.Value) : (TV)currentPair.Value;
					return new KeyValuePair<TK,TV>( (TK)currentPair.Key, val);
				}
			}

			public void Dispose() {
				Enumerator = null;
			}

			object IEnumerator.Current {
				get { return Current; }
			}

			bool IEnumerator.MoveNext() {
				return MoveNext();
			}

			void IEnumerator.Reset() {
				Reset();
			}
		}


	}
}
