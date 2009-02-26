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
using System.Collections.Generic;
using System.Text;

namespace NReco.Providers {
	
	/// <summary>
	/// Performs 'map' operation over list items.
	/// </summary>
	public class MapListProvider<ContextT,ItemT> : IProvider<ContextT,IList<ItemT>> {

		public bool IgnoreNullResult { get; set; }

		public IProvider<ContextT, IEnumerable> ItemsProvider { get; set; }

		public IProvider<MapListContext<ContextT>,ItemT> MapProvider { get; set; }

		public MapListProvider() {
			IgnoreNullResult = false;
		}

		public IList<ItemT> Provide(ContextT context) {
			var items = ItemsProvider!=null ? ItemsProvider.Provide(context) : (IEnumerable)context;
			var itemContext = new MapListContext<ContextT>() { ParentContext = context };
			int index = 0;
			var resList = new List<ItemT>();
			foreach (var itemObj in items) {
				itemContext.Index = index++;
				itemContext.Item = itemObj;
				var mappedValue = MapProvider.Provide(itemContext);
				if (IgnoreNullResult && mappedValue == null)
					continue;
				resList.Add(mappedValue);
			}
			return resList;
		}

	}

	public class MapListContext<T> : Context {
		public T ParentContext { get; set; }
		public object Item { get; set; }
		public int Index { get; set; }
	}

	/// <summary>
	/// Object list map provider
	/// </summary>
	public class MapListProvider : MapListProvider<object,object> {

		public MapListProvider() { }

	}


}
