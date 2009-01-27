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
			ActionContext context = new ActionContext(e) { Sender = sender, Origin = this };
			WebManager.ExecuteAction(context);
		}

		#region Details View Handlers

		public virtual void DetailsViewItemCommandHandler(Object sender, DetailsViewCommandEventArgs e) {
			CommandHandler(sender, e);
		}

		public virtual void DetailsViewDeletedHandler(object sender, DetailsViewDeletedEventArgs e) {
			WebManager.ExecuteAction(
					new ActionContext("Delete") { Sender = sender, Origin = this, Args = e } );
		}

		public virtual void DetailsViewDeletingHandler(object sender, DetailsViewDeleteEventArgs e) {
			WebManager.ExecuteAction(
					new ActionContext("Delete") { Sender = sender, Origin = this, Args = e });
		}

		public virtual void DetailsViewInsertingHandler(object sender, DetailsViewInsertEventArgs e) {
			WebManager.ExecuteAction(
					new ActionContext("Insert") { Sender = sender, Origin = this, Args = e });
		}

		public virtual void DetailsViewInsertedHandler(object sender, DetailsViewInsertedEventArgs e) {
			WebManager.ExecuteAction(
					new ActionContext("Insert") { Sender = sender, Origin = this, Args = e });
		}

		public virtual void DetailsViewUpdatingHandler(object sender, DetailsViewUpdateEventArgs e) {
			WebManager.ExecuteAction(
					new ActionContext("Update") { Sender = sender, Origin = this, Args = e });
		}

		public virtual void DetailsViewUpdatedHandler(object sender, DetailsViewUpdatedEventArgs e) {
			WebManager.ExecuteAction(
					new ActionContext("Update") { Sender = sender, Origin = this, Args = e });
		}
		#endregion

		#region Form View Handlers

		public virtual void FormViewItemCommandHandler(Object sender, FormViewCommandEventArgs e) {
			CommandHandler(sender, e);
		}

		public virtual void FormViewDeletedHandler(object sender, FormViewDeletedEventArgs e) {
			WebManager.ExecuteAction(
					new ActionContext("Delete") { Sender = sender, Origin = this, Args = e });
		}

		public virtual void FormViewDeletingHandler(object sender, FormViewDeleteEventArgs e) {
			WebManager.ExecuteAction(
					new ActionContext("Delete") { Sender = sender, Origin = this, Args = e });
		}

		public virtual void FormViewInsertingHandler(object sender, FormViewInsertEventArgs e) {
			WebManager.ExecuteAction(
					new ActionContext("Insert") { Sender = sender, Origin = this, Args = e });
		}

		public virtual void FormViewInsertedHandler(object sender, FormViewInsertedEventArgs e) {
			WebManager.ExecuteAction(
					new ActionContext("Insert") { Sender = sender, Origin = this, Args = e });
		}

		public virtual void FormViewUpdatingHandler(object sender, FormViewUpdateEventArgs e) {
			WebManager.ExecuteAction(
					new ActionContext("Update") { Sender = sender, Origin = this, Args = e });
		}

		public virtual void FormViewUpdatedHandler(object sender, FormViewUpdatedEventArgs e) {
			WebManager.ExecuteAction(
					new ActionContext("Update") { Sender = sender, Origin = this, Args = e });
		}

		#endregion

	}
}
