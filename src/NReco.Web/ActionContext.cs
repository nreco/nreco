using System;
using System.Collections.Generic;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace NReco.Web {
	
	/// <summary>
	/// Web UI action context class.
	/// </summary>
	public class ActionContext : NameValueContext {
		CommandEventArgs _Command;
		Control _Sender = null;

		public Control Sender {
			get { return _Sender; }
			set { _Sender = value; }
		}

		public CommandEventArgs Command {
			get { return _Command; }
			set { _Command = value; }
		}

		public ActionContext() {
		}

		public ActionContext(Control sender, CommandEventArgs cmd) {
			_Sender = sender;
			_Command = cmd;
		}

	}

}
