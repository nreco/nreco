#region License
/*
 * NReco library (http://code.google.com/p/nreco/)
 * Copyright 2008 Vitaliy Fedorchenko
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
		/// <remarks>Any number of action handlers could be appended to action context.</remarks>
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
		/// <remarks>Usually this is reference to button presses and so on. May be null.</remarks>
		public object Sender {
			get { return _Sender; }
			set { _Sender = value; }
		}

		/// <summary>
		/// Action origin control
		/// </summary>
		/// <remarks>
		/// Reference to 'origin' control where UI action appears. 
		/// Usually this is user control based on ActionUserControl class. May be null.
		/// </remarks>
		public Control Origin {
			get { return _Origin; }
			set { _Origin = value; }
		}

		/// <summary>
		/// Action command args
		/// </summary>
		/// <remarks>May be null.</remarks>
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
