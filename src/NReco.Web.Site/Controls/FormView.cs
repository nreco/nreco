using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Reflection;
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

	}
}
