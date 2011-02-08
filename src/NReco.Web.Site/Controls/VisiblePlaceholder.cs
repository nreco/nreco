using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NReco.Web.Site.Controls {
	public class VisiblePlaceholder : System.Web.UI.WebControls.PlaceHolder {
		public override void DataBind() {
			OnDataBinding(EventArgs.Empty);
			if (Visible) {
				base.DataBind();
			}
		}
	}
}
