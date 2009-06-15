using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using NReco.Collections;

namespace NReco.Web.Site.Controls {
	
	public class FilterView : PlaceHolder, IDataItemContainer {

		public IOrderedDictionary Values { get; set; }

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

		}

		protected override bool OnBubbleEvent(object source, EventArgs args) {
			if (source is IButtonControl) {
				var btn = (IButtonControl)source;
				if (btn.CommandName.ToLower() == "Filter") {
					bool valid = true;
					if (btn.CausesValidation && Page != null) {
						this.Page.Validate(btn.ValidationGroup);
						valid = Page.IsValid;
						HandleFilter();
					}
				}
			}

			return base.OnBubbleEvent(source, args);
		}

		protected void HandleFilter() {

		}

		protected override void CreateChildControls() {
			base.CreateChildControls();
			Values = new OrderedDictionary() { { "filter_title", "ZZZ" } };
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



	}

}
