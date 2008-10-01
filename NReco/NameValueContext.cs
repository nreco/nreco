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
