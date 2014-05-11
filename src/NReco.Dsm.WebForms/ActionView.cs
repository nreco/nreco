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

using NReco.Application.Web;

namespace NReco.Dsm.WebForms {
	
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

		protected override void OnInit(EventArgs e) {
			base.OnInit(e);
			if (Page!=null)
				Page.RegisterRequiresControlState(this);
		}

		protected override object SaveControlState() {
			var obj = base.SaveControlState();
			ExtractValues();
			return new Pair(obj, Values);
		}

		protected override void LoadControlState(object state) {
			var p = state as Pair;
			if (p != null) {
				base.LoadControlState(p.First);
				if (p.Second is IOrderedDictionary)
					Values = (IOrderedDictionary)p.Second;
			} else {
				base.LoadControlState(state);
			}
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

			var actionArgs = new ActionViewEventArgs(cmdName, cmdArg, Values);
			AppContext.EventBroker.Publish(this, actionArgs);
		}

		protected override void CreateChildControls() {
			base.CreateChildControls();
			if (Template != null) {
				Template.InstantiateIn(this);
			}
			if (Page.IsPostBack)
				DataBind(false);
			else
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

		public class ActionViewEventArgs : ActionEventArgs {
			
			public IOrderedDictionary Values { get; private set; }

			public string Argument { get; private set; }

			public ActionViewEventArgs(string cmdName, string cmdArg, IOrderedDictionary values)
				: base(cmdName) {
				Values = values;
				Argument = cmdArg;
			}
		}

	}

}
