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
using System.Linq;
using System.Text;
using System.Web;
using System.Reflection;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace NReco.Web.Site.Controls {
	
	/// <summary>
	/// FormView extended with ability to define dataitem context for insert mode.
	/// </summary>
	public class FormView : System.Web.UI.WebControls.FormView {

		/// <summary>
		/// Get or set dataitem object for insert mode.
		/// </summary>
		public object InsertDataItem { get; set; }

		public FormView() {

		}
		
		public override object DataItem {
			get {
				if (CurrentMode == FormViewMode.Insert && InsertDataItem!=null) {
					return InsertDataItem;
				}
				return base.DataItem;
			}
		}

		public object LoadDataItem() {
			if (CurrentMode == FormViewMode.Insert)
				return null;
			var dataSourceView = GetData();
			var selectArguments = CreateDataSourceSelectArguments();
			object res = null;
			DataSourceViewSelectCallback selectCallback = delegate(IEnumerable data) {
				foreach (var dataEntry in data) {
					res = dataEntry;
					break;
				}
			};
			//this will fail for really async datasource. TBD: investigate how to handle async correctly
			dataSourceView.Select(selectArguments, selectCallback);
			return res;
		}



	}
}
