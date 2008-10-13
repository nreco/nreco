using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;

namespace NReco.Collections {
	
	/// <summary>
	/// List wrapper that makes generic IList compatible with non-generic IList
	/// </summary>
	/// <typeparam name="T">list item type</typeparam>
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
