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
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace NReco.Application.Web.Forms {
	
	/// <summary>
	/// Web UI action context class.
	/// </summary>
	public class ActionEventArgs : EventArgs {
        bool _ResponseEndRequested = false;

		/// <summary>
		/// Action event args
		/// </summary>
		/// <remarks>May be null.</remarks>
		public EventArgs Args { get; set; }

		/// <summary>
		/// Get or set action name
		/// </summary>
		public string ActionName { get; private set; }

        public bool ResponseEndRequested {
            get { return _ResponseEndRequested; }
            set { _ResponseEndRequested = value; }
        }

		public ActionEventArgs() {
		}

		public ActionEventArgs(string actionName) {
			ActionName = actionName;
		}

		public ActionEventArgs(string actionName, EventArgs args) {
			ActionName = actionName;
			Args = args;
		}

	}

}
