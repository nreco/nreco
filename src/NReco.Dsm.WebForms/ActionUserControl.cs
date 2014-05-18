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
using System.Reflection;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using NReco.Application.Web;

namespace NReco.Dsm.WebForms {
	
	/// <summary>
	/// Base class for UserControl that can handle UI actions
	/// </summary>
	public class ActionUserControl : System.Web.UI.UserControl {

		public ActionUserControl() {
		}

		protected object GetControlProperty(object o, string propertyName) {
			PropertyInfo pInfo = o.GetType().GetProperty(propertyName);
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
			CommandHandler(sender, new CommandEventArgs(commandName, commandArgument) );
		}

		public virtual void RepeaterItemCommandHandler(object sender, RepeaterCommandEventArgs e) {
			CommandHandler(sender, e);
		}

		public virtual void DataListItemCommandHandler(Object sender, DataListCommandEventArgs e) {
			CommandHandler(sender, e);
		}

		public virtual void CommandHandler(Object sender, CommandEventArgs e) {
			var args = new ActionEventArgs(e.CommandName, e);
			AppContext.EventBroker.PublishInTransaction(this, args);
			if (args.ResponseEndRequested)
				Response.End();
		}

		public virtual void DetailsViewItemCommandHandler(Object sender, DetailsViewCommandEventArgs e) {
			CommandHandler(sender, e);
		}

		public virtual void FormViewItemCommandHandler(Object sender, FormViewCommandEventArgs e) {
			CommandHandler(sender, e);
		}

	}
}
