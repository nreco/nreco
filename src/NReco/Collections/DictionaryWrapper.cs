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

namespace NReco.Collections {
	
	public class DictionaryWrapper<TKey,TValue> : IDictionary {
		IDictionary<TKey,TValue> Map;

		public DictionaryWrapper(IDictionary<TKey,TValue> map) {
			this.Map = map;
		}

		#region IDictionary Members

		public void Add(object key, object value) {
			Map.Add( (TKey)key, (TValue)value);
		}

		public void Clear() {
			Map.Clear();
		}

		public bool Contains(object key) {
			return Map.ContainsKey( (TKey)key );
		}

		public IDictionaryEnumerator GetEnumerator() {
			return new DictionaryEnumeratorWrapper<TKey,TValue>(Map.GetEnumerator());
		}

		public bool IsFixedSize {
			get { return Map.IsReadOnly; }
		}

		public bool IsReadOnly {
			get { return Map.IsReadOnly; }
		}

		public ICollection Keys {
			get { return new CollectionWrapper<TKey>(Map.Keys); }
		}

		public void Remove(object key) {
			Map.Remove( (TKey)key);
		}

		public ICollection Values {
			get { return new CollectionWrapper<TValue>(Map.Values); }
		}

		public object this[object key] {
			get {
				var mapKey = (TKey) key;
				if (Map.ContainsKey(mapKey))
					return Map[ (TKey) key ];
				return null; // this is usual behaviour in many IDictionary implementations like Hashtable
			}
			set {
				Map[ (TKey)key ] = (TValue)value;
			}
		}

		#endregion

		#region ICollection Members

		public void CopyTo(Array array, int index) {
			int i = 0;
			foreach (DictionaryEntry entry in this) {
				array.SetValue(entry,index+i);
				i++;
			}
		}

		public int Count {
			get { return Map.Count; }
		}

		public bool IsSynchronized {
			get { return false; }
		}

		public object SyncRoot {
			get { return Map; }
		}

		#endregion

		#region IEnumerable Members

		IEnumerator IEnumerable.GetEnumerator() {
			return new DictionaryEnumeratorWrapper<TKey,TValue>(Map.GetEnumerator());
		}

		#endregion

		private sealed class DictionaryEnumeratorWrapper<TKey,TValue> : IDictionaryEnumerator {
			IEnumerator<KeyValuePair<TKey,TValue>> Enumerator;

			public DictionaryEnumeratorWrapper(IEnumerator<KeyValuePair<TKey, TValue>> enumerator) {
				this.Enumerator = enumerator;
				Reset();
			}

			public void Reset () {
				Enumerator.Reset();
			}

			public bool MoveNext () {
				return Enumerator.MoveNext();
			}

			public DictionaryEntry Entry {
				get {
					KeyValuePair<TKey,TValue> currentPair = Enumerator.Current;
					return new DictionaryEntry (currentPair.Key, currentPair.Value);
				}
			}

			public Object Key {
				get {
					return Enumerator.Current.Key;
				}
			}

			public Object Value {
				get {
					return Enumerator.Current.Value;
				}
			}

			public Object Current {
				get { return Entry; }
			}
			
		}
	}
}
