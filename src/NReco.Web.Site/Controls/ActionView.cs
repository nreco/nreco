#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2010 Vitaliy Fedorchenko
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
using System.Collections.Specialized;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using NReco.Collections;

namespace NReco.Web.Site.Controls {
	
	/// <summary>
	/// Action form container (UI parameters container).
	/// </summary>
	[ParseChildren(true, "Template")]
	public class ActionView : Control, IDataItemContainer, INamingContainer {

		public IOrderedDictionary Values { get; set; }

		[DefaultValue(null),TemplateContainer(typeof(ActionView), BindingDirection.TwoWay)]
		public ITemplate Template { get; set; }

		public object DataItem {
			get {
				return new DictionaryView(Values);
			}
		}

		public int DataItemIndex {
			get { return 0; }
		}

		public int DisplayIndex {
			get { return 0; }
		}

		public ActionView() {
			Values = new OrderedDictionary();
			EnableViewState = false;
		}

		protected override bool OnBubbleEvent(object source, EventArgs args) {
			if (source is IButtonControl) {
				var btn = (IButtonControl)source;
				bool valid = true;
				if (btn.CausesValidation && Page != null) {
					this.Page.Validate(btn.ValidationGroup);
					valid = Page.IsValid;
				}
				if (valid) {
					ExecuteAction(btn.CommandName, btn.CommandArgument);
				}
			}

			return base.OnBubbleEvent(source, args);
		}
		
		protected void ExecuteAction(string cmdName, string cmdArg) {
			ExtractValues();

			var cmdArgs = new ActionViewEventArgs(Values,cmdName,cmdArg);
			WebManager.ExecuteAction(
				new ActionContext(cmdArgs) {
					Origin = NamingContainer,
					Sender = this
				});
		}

		protected override void CreateChildControls() {
			base.CreateChildControls();
			if (Template != null) {
				Template.InstantiateIn(this);
			}
			DataBind();
		}

		public void ExtractValues() {
			if (Values == null)
				Values = new OrderedDictionary();
			ExtractValues(Values, this);
			if (Template is IBindableTemplate)
				foreach (DictionaryEntry entry in ((IBindableTemplate)Template).ExtractValues(this))
					Values[entry.Key] = entry.Value;
		}

		protected void ExtractValues(IOrderedDictionary dictionary, Control container) {
			IBindableControl control = container as IBindableControl;
			if (control != null) {
				control.ExtractValues(dictionary);
			}
			foreach (Control c in container.Controls) {
				ExtractValues(dictionary, c);
			}
		}

		public class ActionViewEventArgs : CommandEventArgs {
			IOrderedDictionary _Values;

			public IOrderedDictionary Values {
				get { return _Values; }
			}

			public ActionViewEventArgs(IOrderedDictionary values, string cmdName, string cmdArg)
				: base(cmdName, cmdArg) {
				_Values = values;
			}
		}

	}

}
