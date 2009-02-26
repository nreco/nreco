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
using System.Reflection;
using System.Text;
using System.Data;

namespace NReco.Collections {

	/// <summary>
	/// Dictionary wrapper over any object.
	/// </summary>
	public class ObjectDictionaryWrapper : IDictionary, ICollection {
		object Obj;
		Type ObjType;

		public ObjectDictionaryWrapper(object obj) {
			Obj = obj;
			ObjType = obj.GetType();
		}

		public bool IsFixedSize { get { return true; } }

		public bool IsReadOnly { get { return false; } }

		public object this[object key] {
			get {
				if (!(key is string))
					throw new ArgumentException();
				string keyStr = (string)key;
				var propInfo = ObjType.GetProperty(keyStr);
				if (propInfo != null) {
					return propInfo.GetValue(Obj, null);
				} else
					return null;
			}
			set {
				if (!(key is string))
					throw new ArgumentException();
				string keyStr = (string)key;
				var propInfo = ObjType.GetProperty(keyStr);
				if (propInfo != null) {
					propInfo.SetValue(Obj, value, null);
				}
				else
					throw new ArgumentException();				
			}
		}

		public ICollection Keys {
			get {
				var props = ObjType.GetProperties();
				return Array.ConvertAll(props, 
					new Converter<PropertyInfo,string>(
						 delegate(PropertyInfo p) { return p.Name; }));
			}
		}

		public ICollection Values {
			get {
				return null;

			}
		}

		public void Add(object key, object value) {
			throw new NotSupportedException();
		}

		public void Clear() {
			throw new NotSupportedException();
		}

		public bool Contains(object key) {
			return ObjType.GetProperty(key.ToString()) != null;
		}

		public IDictionaryEnumerator GetEnumerator() {
			return new Enumerator(Obj, ObjType.GetProperties() );
		}

		IEnumerator IEnumerable.GetEnumerator() {
			return GetEnumerator();
		}

		public void Remove(object key) {
			throw new NotSupportedException();
		}

		public bool IsSynchronized {
			get { return false; }
		}

		public int Count {
			get { return ObjType.GetProperties().Length; }
		}

		public void CopyTo(Array array, int index) {
			// what to do ???
		}

		public object SyncRoot {
			get { return Obj; }
		}

		private sealed class Enumerator : IDictionaryEnumerator {

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

			public DictionaryEntry Entry {
				get {
					if (currentKey == null) throw new InvalidOperationException();
					return new DictionaryEntry(currentKey, currentValue);
				}
			}

			public Object Key {
				get {
					if (currentKey == null) throw new InvalidOperationException();
					return currentKey;
				}
			}

			public Object Value {
				get {
					if (currentKey == null) throw new InvalidOperationException();
					return currentValue;
				}
			}

			public Object Current {
				get { return Entry; }
			}
		}

	}

}
