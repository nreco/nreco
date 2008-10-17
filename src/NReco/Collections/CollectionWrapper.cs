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
using System.Text;
using System.Collections;

namespace NReco.Collections {

	/// <summary>
	/// List wrapper that makes generic ICollection compatible with non-generic ICollection
	/// </summary>
	/// <typeparam name="T">collection item type</typeparam>
	public class CollectionWrapper<T> : ICollection {
		ICollection<T> Collection;

		public CollectionWrapper(ICollection<T> collection) {
			this.Collection = collection;
		}

		public void CopyTo(Array array, int index) {
			T[] colArray = new T[Collection.Count];
			Collection.CopyTo(colArray,0);
			for (int i = 0; i < colArray.Length; i++)
				array.SetValue(colArray[i], index + i);
		}

		public int Count {
			get { return Collection.Count; }
		}

		public bool IsSynchronized {
			get { return false; }
		}

		public object SyncRoot {
			get { return Collection; }
		}

		public IEnumerator GetEnumerator() {
			return Collection.GetEnumerator();
		}

	}
}
