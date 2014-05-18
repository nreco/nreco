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
using System.Collections;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using NReco.Application.Web;

namespace NReco.Dsm.WebForms {
	
	/// <summary>
	/// Action data source used for wrapping another data source for processing select/insert/update/delete operations through web action mechanism.
	/// </summary>
	public class ActionDataSource : DataSourceControl {
		IDataSource _UnderlyingSource = null;
		public string DataSourceID { get; set; }

        public ActionDataSource() {
        }

		/// <summary>
		/// Get instance of underlying data source
		/// </summary>
		public IDataSource UnderlyingSource {
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

		protected override void OnInit(EventArgs e) {
			AppContext.EventBroker.Subscribe<DataSourceViewEventArgs>(HandleDataSourceActions);
			base.OnInit(e);
		}

		protected void HandleDataSourceActions(object sender, DataSourceViewEventArgs args) {
			if (sender != this)
				return; // handle events of this data source only
			if (args is SelectEventArgs) {
				var select = (SelectEventArgs)args;
				select.DataSourceView.Select(select.SelectArgs, select.Callback);
			} else if (args is InsertEventArgs) {
				var insert = (InsertEventArgs)args;
				insert.DataSourceView.Insert(insert.Values, insert.Callback);
			} else if (args is UpdateEventArgs) {
				var update = (UpdateEventArgs)args;
				update.DataSourceView.Update(update.Keys, update.Values, update.OldValues, update.Callback);
			} else if (args is DeleteEventArgs) {
				var delete = (DeleteEventArgs)args;
				delete.DataSourceView.Delete(delete.Keys, delete.OldValues, delete.Callback);				
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
			ActionDataSource ActionDS;

			public ActionDataSourceView(ActionDataSource source, string viewName, DataSourceView underlyingDataSourceView)
				: base(source, viewName) {
				UnderlyingView = underlyingDataSourceView;
				ActionDS = source;
			}

			protected override IEnumerable ExecuteSelect(DataSourceSelectArguments arguments) {
				IEnumerable callbackResult = null;
				DataSourceViewSelectCallback syncCallback = delegate(IEnumerable result) {
					callbackResult = result;
				};
				Select(arguments, syncCallback);
				return callbackResult;
			}

			public override void Select(DataSourceSelectArguments arguments, DataSourceViewSelectCallback callback) {
				var selectArgs = new SelectEventArgs() { 
						DataSourceView = UnderlyingView, 
						SelectArgs = arguments };
				
				selectArgs.Callback = delegate(IEnumerable data) {
					selectArgs.Data = data;
					callback(data);
				};

				AppContext.EventBroker.Publish(ActionDS, selectArgs);
			}

			public override void Delete(IDictionary keys, IDictionary oldValues, DataSourceViewOperationCallback callback) {
				var deleteArgs = new DeleteEventArgs() {
					DataSourceView = UnderlyingView, Callback = callback,
					OldValues = oldValues, Keys = keys
				};
				AppContext.EventBroker.PublishInTransaction(ActionDS, deleteArgs);
			}

			public override void Insert(IDictionary values, DataSourceViewOperationCallback callback) {
                var insertArgs = new InsertEventArgs() { 
                            DataSourceView = UnderlyingView, Callback = callback, Values = values };
				AppContext.EventBroker.PublishInTransaction(ActionDS, insertArgs);
			}

			public override void Update(IDictionary keys, IDictionary values, IDictionary oldValues, DataSourceViewOperationCallback callback) {
				var updateArgs = new UpdateEventArgs() { 
							
						    DataSourceView = UnderlyingView, Callback = callback, 
						    Values = values, OldValues = oldValues, Keys = keys };
				AppContext.EventBroker.PublishInTransaction(ActionDS, updateArgs);
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


		public abstract class DataSourceViewEventArgs : ActionEventArgs {
            public DataSourceView DataSourceView { get; set; }

			public DataSourceViewEventArgs(string actionName) : base(actionName) { }
        }

        public class SelectEventArgs : DataSourceViewEventArgs {
			public DataSourceView DataSourceView { get; set; }
			public DataSourceSelectArguments SelectArgs { get; set; }
			public DataSourceViewSelectCallback Callback { get; set; }
			public IEnumerable Data { get; set; }

            public SelectEventArgs() : base("Select") 
            {
                Data = null;
            }
        }

		public abstract class DataSourceViewOperationEventArgs : DataSourceViewEventArgs {
			public DataSourceViewOperationCallback Callback { get; set; }

			public DataSourceViewOperationEventArgs(string actionName) : base(actionName) { }
		}

		public class InsertEventArgs : DataSourceViewOperationEventArgs {
			public IDictionary Values { get; set; }

			public InsertEventArgs() : base("Insert") {
			}
		}

		public class DeleteEventArgs : DataSourceViewOperationEventArgs {
			public IDictionary OldValues { get; set; }
			public IDictionary Keys { get; set; }

			public DeleteEventArgs() : base("Delete") {
			}
		}

		public class UpdateEventArgs : DataSourceViewOperationEventArgs {
			public IDictionary OldValues { get; set; }
			public IDictionary Values { get; set; }
			public IDictionary Keys { get; set; }

			public UpdateEventArgs() : base("Update") {
			}
		}

	}
}
