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
using System.Collections;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace NReco.Web {
	
	/// <summary>
	/// Action data source used for wrapping another data source for processing select/insert/update/delete operations through web action mechanism.
	/// </summary>
	public class ActionDataSource : DataSourceControl {
		IDataSource _UnderlyingSource = null;

		public string DataSourceID { get; set; }

		protected IDataSource UnderlyingSource {
			get {
				if (_UnderlyingSource == null && DataSourceID!=null) {
					Control c = this.NamingContainer;
					while (c != null && _UnderlyingSource==null) {
						_UnderlyingSource = c.FindControl(DataSourceID) as IDataSource;
						c = c.NamingContainer;
					}

				}
				return _UnderlyingSource;
			}
		}

		protected override DataSourceView GetView(string viewName) {
			DataSourceView view = UnderlyingSource!=null ? UnderlyingSource.GetView(viewName) : null;
			return new ActionDataSourceView(this, viewName, view);
		}

		protected override ICollection GetViewNames() {
			if (UnderlyingSource == null)
				return new string[] { String.Empty };
			return UnderlyingSource.GetViewNames();
		}

		public class ActionDataSourceView : DataSourceView {
			DataSourceView UnderlyingView;
			ActionDataSource ActionSource;

			public ActionDataSourceView(ActionDataSource source, string viewName, DataSourceView underlyingDataSourceView)
				: base(source, viewName) {
				UnderlyingView = underlyingDataSourceView;
				ActionSource = source;
			}

			protected override IEnumerable ExecuteSelect(DataSourceSelectArguments arguments) {
				return null;
			}

			public override void Select(DataSourceSelectArguments arguments, DataSourceViewSelectCallback callback) {
				WebManager.ExecuteAction(
					new ActionContext(
						new SelectEventArgs() { DataSourceView = UnderlyingView, Callback = callback, SelectArgs = arguments }
					) { Origin = ActionSource.NamingContainer, Sender = ActionSource });
			}

			public override void Delete(IDictionary keys, IDictionary oldValues, DataSourceViewOperationCallback callback) {
				WebManager.ExecuteAction(
					new ActionContext(
						new DeleteEventArgs() { DataSourceView = UnderlyingView, Callback = callback, OldValues = oldValues, Keys = keys }
					) { Origin = ActionSource.NamingContainer, Sender = ActionSource });
			}

			public override void Insert(IDictionary values, DataSourceViewOperationCallback callback) {
				WebManager.ExecuteAction(
					new ActionContext(
						new InsertEventArgs() { DataSourceView = UnderlyingView, Callback = callback, Values = values }
					) { Origin = ActionSource.NamingContainer, Sender = ActionSource });
			}

			public override void Update(IDictionary keys, IDictionary values, IDictionary oldValues, DataSourceViewOperationCallback callback) {
				WebManager.ExecuteAction(
					new ActionContext(
						new UpdateEventArgs() { 
							DataSourceView = UnderlyingView, Callback = callback, 
							Values = values, OldValues = oldValues, Keys = keys }
						) { Origin = ActionSource.NamingContainer, Sender = ActionSource } );
			}


			public override bool CanDelete {
				get {
					if (UnderlyingView != null)
						return UnderlyingView.CanDelete;
					return true;
				}
			}

			public override bool CanUpdate {
				get {
					if (UnderlyingView != null)
						return UnderlyingView.CanUpdate;
					return true;
				}
			}

			public override bool CanInsert {
				get {
					if (UnderlyingView != null)
						return UnderlyingView.CanInsert;
					return true;
				}
			}	

			public override bool CanPage {
				get {
					if (UnderlyingView != null)
						return UnderlyingView.CanPage;
					return false;
				}
			}

			public override bool CanSort {
				get {
					if (UnderlyingView != null)
						return UnderlyingView.CanSort;
					return false;
				}
			}

			public override bool CanRetrieveTotalRowCount {
				get {
					if (UnderlyingView != null)
						return UnderlyingView.CanRetrieveTotalRowCount;
					return false;
				}
			}


		}

		public class SelectEventArgs : CommandEventArgs {

			public DataSourceView DataSourceView { get; set; }
			public DataSourceViewSelectCallback Callback { get; set; }
			public DataSourceSelectArguments SelectArgs { get; set; }

			public SelectEventArgs()
				: base("Select", null) {
			}

		}

		public class InsertEventArgs : CommandEventArgs {
			public DataSourceView DataSourceView { get; set; }
			public DataSourceViewOperationCallback Callback { get; set; }
			public IDictionary Values { get; set; }

			public InsertEventArgs()
				: base("Insert", null) {
			}
		}

		public class DeleteEventArgs : CommandEventArgs {
			public DataSourceView DataSourceView { get; set; }
			public DataSourceViewOperationCallback Callback { get; set; }
			public IDictionary OldValues { get; set; }
			public IDictionary Keys { get; set; }

			public DeleteEventArgs()
				: base("Delete", null) {
			}
		}

		public class UpdateEventArgs : CommandEventArgs {
			public DataSourceView DataSourceView { get; set; }
			public DataSourceViewOperationCallback Callback { get; set; }
			public IDictionary OldValues { get; set; }
			public IDictionary Values { get; set; }
			public IDictionary Keys { get; set; }

			public UpdateEventArgs()
				: base("Update", null) {
			}
		}

	}
}
