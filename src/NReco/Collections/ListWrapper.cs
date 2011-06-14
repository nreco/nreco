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

namespace NReco.Collections {
	
	/// <summary>
	/// List wrapper that makes generic IList compatible with non-generic IList
	/// </summary>
	/// <typeparam name="T">list item type</typeparam>
	[Serializable]
	public class ListWrapper<T> : CollectionWrapper<T>, IList {
		IList<T> List;

		public ListWrapper(IList<T> list) : base(list) {
			this.List = list;
		}

		#region IList Members

		public int Add(object value) {
			List.Add( (T)value);
			return List.Count-1;
		}

		public void Clear() {
			List.Clear();
		}

		public bool Contains(object value) {
			return List.Contains( (T)value );
		}

		public int IndexOf(object value) {
			return List.IndexOf( (T)value );
		}

		public void Insert(int index, object value) {
			List.Insert(index, (T)value);
		}

		public bool IsFixedSize {
			get { return List.IsReadOnly; }
		}

		public bool IsReadOnly {
			get { return List.IsReadOnly; }
		}

		public void Remove(object value) {
			List.Remove( (T)value );
		}

		public void RemoveAt(int index) {
			List.RemoveAt(index);
		}

		public object this[int index] {
			get {
				return List[index];
			}
			set {
				List[index] = (T)value;
			}
		}

		#endregion


	}
}
