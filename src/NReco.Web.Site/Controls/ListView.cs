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
using System.Linq;
using System.Text;
using System.Web;
using System.Reflection;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace NReco.Web.Site.Controls {
	
	/// <summary>
	/// ListView extended with ability to define dataitem context for insert mode.
	/// </summary>
	public class ListView : System.Web.UI.WebControls.ListView {

		/// <summary>
		/// Get or set dataitem object for insert mode.
		/// </summary>
		public object InsertDataItem { get; set; }

		public ListView() {

		}

		protected override void InstantiateInsertItemTemplate(Control container) {
			if (container is ListViewInsertItem)
				((ListViewInsertItem)container).DataItem = InsertDataItem;
			base.InstantiateInsertItemTemplate(container);
		}

		protected override ListViewItem CreateItem(ListViewItemType itemType) {
			if (itemType != ListViewItemType.InsertItem) {
				return base.CreateItem(itemType);
			}
			return new ListViewInsertItem();
		}

		protected override void AddControlToContainer(Control control, Control container, int addLocation) {
			base.AddControlToContainer(control, container, addLocation);
			if (control is ListViewInsertItem)
				((ListViewInsertItem)control).DataBind();
		}

		public class ListViewInsertItem : ListViewItem, IDataItemContainer, INamingContainer {

			public ListViewInsertItem() : base(ListViewItemType.InsertItem) {

			}

			public object DataItem { get; set; }

			public int DataItemIndex { get { return 0; } }
			public int DisplayIndex { get { return 0; } }

		}


	}
}
