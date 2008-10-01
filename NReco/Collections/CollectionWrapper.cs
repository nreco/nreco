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
