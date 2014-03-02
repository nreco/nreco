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
using System.Collections.Generic;
using System.Text;

namespace NReco.Statements {
	
	/// <summary>
	/// Each list operation. Just executes specified operation over list items.
	/// </summary>
	public class Each : IStatement {

		public string ItemKey { get; set; }

		public string ItemIndexKey { get; set; }

		public IStatement ItemAction { get; private set; }

		public Func<IDictionary<string,object>,IEnumerable> GetItems { get; private set; }

		public Each(Func<IDictionary<string,object>,IEnumerable> getItems, IStatement itemAction, string itemKey) {
			GetItems = getItems;
			ItemAction = itemAction;
			ItemKey = itemKey;
		}

		public void Execute(IDictionary<string,object> context) {
			var items = GetItems(context);
			int index = 0;
			foreach (var itm in items) {
				if (ItemIndexKey != null)
					context[ItemIndexKey] = index;

				context[ItemKey] = itm;
				ItemAction.Execute(context);

				index++;
			}
		}

	}


}
