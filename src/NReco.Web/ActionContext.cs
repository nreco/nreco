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
		CommandEventArgs _Args;
		object _Sender = null;
		Control _Origin = null;
		IList<IOperation<ActionContext>> _Handlers = null;

		/// <summary>
		/// Action handlers
		/// </summary>
		public IList<IOperation<ActionContext>> Handlers {
			get {
				if (_Handlers == null)
					_Handlers = new List<IOperation<ActionContext>>();
				return _Handlers; 
			}
		}

		/// <summary>
		/// Action sender
		/// </summary>
		public object Sender {
			get { return _Sender; }
			set { _Sender = value; }
		}

		/// <summary>
		/// Action origin control
		/// </summary>
		public Control Origin {
			get { return _Origin; }
			set { _Origin = value; }
		}

		/// <summary>
		/// Action command args
		/// </summary>
		public CommandEventArgs Args {
			get { return _Args; }
			set { _Args = value; }
		}

		public ActionContext() {
		}

		public ActionContext(Control origin, object sender, CommandEventArgs cmd) {
			_Sender = sender;
			_Origin = origin;
			_Args = cmd;
		}

	}

}
