#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2013 Vitaliy Fedorchenko
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
using System.Collections;
using System.Linq;
using System.Text;
using System.ComponentModel;

using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace NReco.Application.Web.Forms {
	
	/// <summary>
	/// Bindable view that enables Bind() expressions inside template transparently
	/// </summary>
	[ParseChildren(true, "Template")]
	public class BindableView : Control, IBindableControl, INamingContainer {

		[DefaultValue(null), TemplateContainer(typeof(BindableView), BindingDirection.TwoWay)]
		public ITemplate Template { get; set; }

		public BindableView() {
		}

		protected override void CreateChildControls() {
			base.CreateChildControls();
			if (Template != null) {
				Template.InstantiateIn(this);
			}
		}

		public override void DataBind() {
			EnsureChildControls();
			base.DataBind();
		}

		public void ExtractValues(System.Collections.Specialized.IOrderedDictionary dictionary) {
			if (Template is IBindableTemplate)
				foreach (DictionaryEntry entry in ((IBindableTemplate)Template).ExtractValues(this))
					dictionary[entry.Key] = entry.Value;
		}
		

	}
}
