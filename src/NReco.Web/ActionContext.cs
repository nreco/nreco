#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008,2009 Vitaliy Fedorchenko
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
        bool _ResponseEndRequested = false;

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
		/// Action event args
		/// </summary>
		/// <remarks>May be null.</remarks>
		public CommandEventArgs Args {
			get { return _Args; }
			set { _Args = value; }
		}

        public bool ResponseEndRequested {
            get { return _ResponseEndRequested; }
            set { _ResponseEndRequested = value; }
        }

		public ActionContext() {
		}

		public ActionContext(string commandName) {
			Args = new CommandEventArgs(commandName, null);
		}

		public ActionContext(CommandEventArgs args) {
			Args = args;
		}

	}

}
