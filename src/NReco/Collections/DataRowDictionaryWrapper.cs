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
using System.Data;

namespace NReco.Collections {

	/// <summary>
	/// Dictionary wrapper over DataRow class.
	/// </summary>
	public class DataRowDictionaryWrapper : IDictionary<string,object> {
		DataRow Row;

		public DataRowDictionaryWrapper(DataRow row) {
			Row = row;
		}

		public bool IsReadOnly { get { return false; } }

		public object this[string key] {
			get {
				if (!Row.Table.Columns.Contains(key))
					throw new KeyNotFoundException();
				return Row[key];
			}
			set {
				if (!Row.Table.Columns.Contains(key))
					throw new KeyNotFoundException();
				Row[key] = value;
			}
		}

		public ICollection<string> Keys {
			get {
				var names = new string[Row.Table.Columns.Count];
				for (int i = 0; i < names.Length; i++)
					names[i] = Row.Table.Columns[i].ColumnName;
				return names;
			}
		}

		public ICollection<object> Values {
			get {
				return Row.ItemArray;
			}
		}

		public void Add(string key, object value) {
			throw new NotSupportedException();
		}

		public void Clear() {
			throw new NotSupportedException();
		}

		public bool Contains(KeyValuePair<string, object> item) {
			if (!ContainsKey(item.Key))
				return false;
			return this[item.Key] == item.Value;
		}

		public bool ContainsKey(string key) {
			return Row.Table.Columns.Contains(key);
		}

		public IEnumerator<KeyValuePair<string, object>> GetEnumerator() {
			return new Enumerator(Row);
		}

		IEnumerator IEnumerable.GetEnumerator() {
			return GetEnumerator();
		}

		public bool Remove(string key) {
			throw new NotSupportedException();
		}

		public int Count {
			get { return Row.Table.Columns.Count; }
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

		public void CopyTo(KeyValuePair<string, object>[] array, int arrayIndex) {
			throw new NotImplementedException();
		}

		public bool Remove(KeyValuePair<string, object> item) {
			throw new NotSupportedException();
		}


		private sealed class Enumerator : IEnumerator<KeyValuePair<string, object>> {

			private DataRow row;
			private int pos;
			private int size;

			private string currentKey;
			private Object currentValue;

			public Enumerator(DataRow row) {
				this.row = row;
				Reset();
			}

			public void Reset() {
				pos = -1;
				size = row.Table.Columns.Count;
				currentKey = null;
				currentValue = null;
			}

			public bool MoveNext() {
				if (pos < (size - 1)) {
					pos++;
					currentKey = row.Table.Columns[pos].ColumnName;
					currentValue = row[currentKey];
					return true;
				}
				currentKey = null;
				currentValue = null;
				return false;
			}

			public KeyValuePair<string, object> Current {
				get {
					if (currentKey == null) throw new InvalidOperationException();
					return new KeyValuePair<string,object>(currentKey, currentValue);
				}
			}

			object IEnumerator.Current {
				get { return Current; }
			}

			public void Dispose() {
				row = null;
			}

		}


	}

}
