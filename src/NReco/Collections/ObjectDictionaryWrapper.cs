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
using System.Reflection;
using System.Text;
using System.Data;

namespace NReco.Collections {

	/// <summary>
	/// Dictionary wrapper over any object.
	/// </summary>
	public class ObjectDictionaryWrapper : IDictionary<string,object> {
		object Obj;
		Type ObjType;

		public ObjectDictionaryWrapper(object obj) {
			Obj = obj;
			ObjType = obj.GetType();
		}

		public bool IsReadOnly { get { return false; } }

		public object this[string key] {
			get {
				var propInfo = ObjType.GetProperty(key);
				if (propInfo != null) {
					return propInfo.GetValue(Obj, null);
				} else
					throw new KeyNotFoundException();
			}
			set {
				var propInfo = ObjType.GetProperty(key);
				if (propInfo != null) {
					propInfo.SetValue(Obj, value, null);
				}
				else
					throw new KeyNotFoundException();				
			}
		}

		public ICollection<string> Keys {
			get { 
				var props = ObjType.GetProperties();
				return Array.ConvertAll(props, p => p.Name);
			}
		}

		public ICollection<object> Values {
			get {
				var props = ObjType.GetProperties();
				return Array.ConvertAll(props, p => p.GetValue(Obj, null) );
			}
		}

		public void Add(string key, object value) {
			throw new NotImplementedException();
		}

		public void Clear() {
			throw new NotSupportedException();
		}


		public bool ContainsKey(string key) {
			return ObjType.GetProperty(key) != null;
		}


		IEnumerator IEnumerable.GetEnumerator() {
			return GetEnumerator();
		}

		public IEnumerator<KeyValuePair<string, object>> GetEnumerator() {
			return new Enumerator(Obj, ObjType.GetProperties());
		}

		public int Count {
			get { return ObjType.GetProperties().Length; }
		}

		public bool Remove(string key) {
			throw new NotSupportedException();
		}

		public bool TryGetValue(string key, out object value) {
			if (!ContainsKey(key)) {
				value = null;
				return false;
			}
			value = this[key];
			return true;
		}

		public void Add(KeyValuePair<string, object> item) {
			throw new NotSupportedException();
		}

		public bool Contains(KeyValuePair<string, object> item) {
			return ContainsKey(item.Key) && this[item.Key]==item.Value;
		}

		public void CopyTo(KeyValuePair<string, object>[] array, int arrayIndex) {
			throw new NotImplementedException();
		}

		public bool Remove(KeyValuePair<string, object> item) {
			throw new NotSupportedException();
		}


		private sealed class Enumerator : IEnumerator<KeyValuePair<string, object>> {

			private object Obj;
			private int pos;
			private int size;

			private string currentKey;
			private Object currentValue;
			PropertyInfo[] props;

			public Enumerator(object o, PropertyInfo[] props) {
				Obj = o;
				this.props = props;
				Reset();
			}


			public void Reset() {
				pos = -1;
				size = props.Length;
				currentKey = null;
				currentValue = null;
			}

			public bool MoveNext() {
				if (pos < (size - 1)) {
					pos++;
					currentKey = props[pos].Name;
					currentValue = props[pos].GetValue(Obj, null);
					return true;
				}
				currentKey = null;
				currentValue = null;
				return false;
			}

			public KeyValuePair<string, object> Current {
				get {
					if (currentKey == null)
						throw new InvalidOperationException();
					return new KeyValuePair<string,object>(currentKey, currentValue); 
				}
			}

			object IEnumerator.Current {
				get { return Current; }
			}

			public void Dispose() {
				
			}

		}

	}

}
