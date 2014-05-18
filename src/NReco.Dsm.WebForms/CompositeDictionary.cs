#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2014 Vitaliy Fedorchenko
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

namespace NReco.Dsm.WebForms
{
	/// <summary>
	/// Composite dictionary implementation
	/// </summary>
    [Serializable]
	public class CompositeDictionary : IDictionary
	{
		
		/// <summary>
		/// Update value if exist in satellite dictionary 
		/// </summary>
		public bool UpdateSatellites { get; set; }
		
		/// <summary>
		/// Get or set master dictionary instance
		/// </summary>
		public IDictionary Master { get; private set; }

		public IDictionary[] Satellites { get; private set; }
		
		public CompositeDictionary(IDictionary master, params IDictionary[] satellites) {
			Master = master;
			Satellites = satellites;
			UpdateSatellites = false;
		}
		
		public bool IsFixedSize { get { return Master.IsFixedSize; } }

		public bool IsReadOnly { get { return Master.IsReadOnly; } }

		public object this[object key] {
			get {
				// try to find in sattelities
				if (Satellites!=null)
					for (int i=0; i<Satellites.Length; i++)
						if (Satellites[i].Contains(key))
							return Satellites[i][key];
				
				return Master[key];
			}
			set {
				Master[key] = value;
				if (Satellites != null && UpdateSatellites)
					for (int i=0; i<Satellites.Length; i++)
						if (Satellites[i].Contains(key))
							Satellites[i][key] = value;
			}
		}

		public ICollection Keys {
			get {
				ArrayList keys = new ArrayList( Master.Keys);
				if (Satellites!=null)
					for (int i=0; i<Satellites.Length; i++)
						foreach (object key in Satellites[i].Keys)
							if (!keys.Contains(key))
								keys.Add(key);
				return keys;
			}
		}

		public ICollection Values {
			get {
				ArrayList values = new ArrayList(Master.Values.Count);
				foreach (object key in Keys)
					values.Add( this[key] );
				return values;
			}
		}

		public void Add (object key, object value) {
			this[key] = value;
		}

		public void Clear () {
			Master.Clear();
		}

		public bool Contains (object key) {
			if (Satellites!=null)
				for (int i=0; i<Satellites.Length; i++)
					if (Satellites[i].Contains(key))
						return true;
			return Master.Contains(key);
		}

		public IDictionaryEnumerator GetEnumerator () {
			return new Enumerator(this);
		}
		
		IEnumerator IEnumerable.GetEnumerator() {
			return GetEnumerator();
		}

		public void Remove (object key) {
			Master.Remove(key);
		}
			
		public bool IsSynchronized {
			get { return Master.IsSynchronized; }
		}

		public int Count {
			get { return Keys.Count; }
		}

		public void CopyTo(Array array, int index) {
			// what to do ???
		}

		public object SyncRoot {
			get { return Master.SyncRoot; }
		}
		
		private sealed class Enumerator : IDictionaryEnumerator {

			private IDictionary Dictionary;
			private IList Keys;
			private int pos;
			private int size;

			private object currentKey;
			private object currentValue;

			public Enumerator(IDictionary dictionary) {
				this.Dictionary = dictionary;
				Keys = dictionary.Keys as IList;
				Reset();
			}

			public void Reset () {
				pos = -1;
				size = Keys.Count;
				currentKey = null;
				currentValue = null;
			}

			public bool MoveNext () {
				if (pos < (size-1) ) {
					pos++;
					currentKey = Keys[pos];
					currentValue = Dictionary[currentKey];
					return true;
				}
				currentKey = null;
				currentValue = null;
				return false;
			}

			public DictionaryEntry Entry {
				get {
					if (currentKey == null) throw new InvalidOperationException ();
					return new DictionaryEntry (currentKey, currentValue);
				}
			}

			public Object Key {
				get {
					if (currentKey == null) throw new InvalidOperationException ();
					return currentKey;
				}
			}

			public Object Value {
				get {
					if (currentKey == null) throw new InvalidOperationException ();
					return currentValue;
				}
			}

			public Object Current {
				get {
					if (currentKey == null) throw new InvalidOperationException ();
					return new DictionaryEntry (currentKey, currentValue);
				}
			}
		
		
		
	}
	
	}
}
