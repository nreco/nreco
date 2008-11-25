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
using System.Reflection;

using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace NReco.Web {
	
	/// <summary>
	/// Base class for UserControl that can handle UI actions
	/// </summary>
	public class ActionUserControl : System.Web.UI.UserControl {

		public ActionUserControl() {
		}

		public virtual void InvokeCommand(object sender, CommandEventArgs cmd) {
			if (cmd.CommandName!=null) {
				MethodInfo execMethodInfo = this.GetType().GetMethod("Execute_"+cmd.CommandName);

			}
		}

		protected object GetControlProperty(object o, string propertyName) {
			PropertyInfo pInfo = o.GetType().GetProperty("CausesValidation");
			if (pInfo!=null) {
				return pInfo.GetValue(o, null);
			}
			return null;
		}

		public virtual void ButtonHandler(object sender, EventArgs e) {
			// check validators
			bool? causesValidation = GetControlProperty(sender,"CausesValidation") as bool?;
			if (causesValidation.HasValue && causesValidation.Value) {
				if (!Page.IsValid) return;
			}

			string commandName = GetControlProperty(sender,"CommandName") as string;
			object commandArgument = GetControlProperty(sender,"CommandArgument");
			InvokeCommand(sender, new CommandEventArgs(commandName, commandArgument) );
		}

		public virtual void RepeaterItemCommandHandler(object sender, RepeaterCommandEventArgs e) {
			InvokeCommand(sender, e);
		}

		public virtual void DataListItemCommandHandler(Object sender, DataListCommandEventArgs e) {
			InvokeCommand(sender, e);
		}

		public virtual void CommandHandler(Object sender, CommandEventArgs e) {
			InvokeCommand(sender, e);
		}


	}
}
