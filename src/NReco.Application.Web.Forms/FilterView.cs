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

namespace NReco.Application.Web.Forms {
	
	/// <summary>
	/// Filter form container (usually used in conjunction with ListView).
	/// </summary>
	[ParseChildren(true, "Template")]
	public class FilterView : Control, IDataItemContainer, INamingContainer {

		public IOrderedDictionary Values { get; set; }

		public event EventHandler<FilterCommandEventArgs> Filter;

		[DefaultValue(null),TemplateContainer(typeof(FilterView), BindingDirection.TwoWay)]
		public ITemplate Template { get; set; }

		object IDataItemContainer.DataItem {
			get {
				return new DictionaryView(Values);
			}
		}

		int IDataItemContainer.DataItemIndex {
			get { return 0; }
		}

		int IDataItemContainer.DisplayIndex {
			get { return 0; }
		}

		public FilterView() {
			Values = new OrderedDictionary();
			EnableViewState = false;
		}

		protected override void OnInit(EventArgs e) {
			base.OnInit(e);
			if (Page != null)
				Page.RegisterRequiresControlState(this);
		}

		protected override object SaveControlState() {
			var obj = base.SaveControlState();
			
			if (Values == null)
				Values = new OrderedDictionary();
			ExtractValues(Values, this);
			
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
				var btnCmd = btn.CommandName.ToLower();
				if (btnCmd == "filter") {
					bool valid = true;
					if (btn.CausesValidation && Page != null) {
						this.Page.Validate(btn.ValidationGroup);
						valid = Page.IsValid;
					}
					if (valid)
						HandleFilter(btn.CommandName, btn.CommandArgument);
				}
				if (btnCmd == "reset") {
					HandleReset(btn.CommandName, btn.CommandArgument);
				}
			}

			return base.OnBubbleEvent(source, args);
		}

		public void ApplyFilter() {
			HandleFilter("Filter", "");
		}

		public void ApplyReset() {
			HandleReset("Reset", "");
		}

		protected void HandleReset(string cmdName, string cmdArg) {
			Values = new OrderedDictionary();
			ExtractValues(Values, this);
			if (Template is IBindableTemplate)
				foreach (DictionaryEntry entry in ((IBindableTemplate)Template).ExtractValues(this))
					Values[entry.Key] = entry.Value;
			// reset all values
            for (int i = 0; i < Values.Count; i++)
                Values[i] = null;
			
			if (Filter != null)
				Filter(this, new FilterCommandEventArgs(Values, cmdName, cmdArg));
			DataBind();
		}

		protected void HandleFilter(string cmdName, string cmdArg) {
			if (Values == null)
				Values = new OrderedDictionary();
			ExtractValues(Values, this);
			if (Template is IBindableTemplate)
				foreach (DictionaryEntry entry in ((IBindableTemplate)Template).ExtractValues(this))
					Values[entry.Key] = entry.Value;
			if (Filter != null)
				Filter(this, new FilterCommandEventArgs(Values, cmdName, cmdArg));
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

		protected void ExtractValues(IOrderedDictionary dictionary, Control container) {
			IBindableControl control = container as IBindableControl;
			if (control != null) {
				control.ExtractValues(dictionary);
			}
			foreach (Control c in container.Controls) {
				ExtractValues(dictionary, c);
			}
		}

		public class FilterCommandEventArgs : CommandEventArgs {
			IOrderedDictionary _Values;

			public IOrderedDictionary Values {
				get { return _Values; }
			}

			public FilterCommandEventArgs(IOrderedDictionary values, string cmdName, string cmdArg) : base(cmdName, cmdArg) {
				_Values = values;
			}
		}

	}

}
