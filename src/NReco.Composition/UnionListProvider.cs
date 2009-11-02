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

namespace NReco.Composition
{
	/// <summary>
	/// Union-type composite list provider implementation.
	/// </summary>
	public class UnionListProvider<Context,T> : IProvider<Context,IList<T>>
	{
		public bool IgnoreNullResult { get; set;  }

		public bool SkipInvalidEntryType { get; set; }

		public IProvider<object, object>[] Providers { get; set; }

		public UnionListProvider() {
			IgnoreNullResult = true;
			SkipInvalidEntryType = false;
		}

		protected bool IsEnumerable(object o) {
			return o is IEnumerable && !(o is string);
		}

		public IList<T> GetList(Context context) {
			IList<T> result = new List<T>();
			for (int i=0; i<Providers.Length; i++) {
				object subList = Providers[i].Provide(context);
				if (subList==null && IgnoreNullResult)
					continue;
				if (subList==null)
					result.Add( (T)subList );
				else if (subList is IList<T>) {
					foreach (T entry in (IList<T>)subList)
						result.Add(entry);
				} else if (IsEnumerable(subList)) {
					foreach (object o in (IEnumerable)subList) {
						if (SkipInvalidEntryType) {
							if (o is T)
								result.Add( (T)o );
						} else
							result.Add( (T)o );
					}

				} else if (subList is T) {
					result.Add((T)subList);
				} else {
					if (!SkipInvalidEntryType)
						result.Add((T)subList);
				}
				
			}
			return result;
		}

		public IList<T> Provide(Context context) {
			return GetList(context);
		}

	}

	/// <summary>
	/// Union-type composition provider (non-generic variant)
	/// </summary>
	public class UnionListProvider : UnionListProvider<object,object> {
		public UnionListProvider() { }
	}

}
