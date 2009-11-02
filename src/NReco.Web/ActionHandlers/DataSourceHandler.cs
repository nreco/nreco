using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI.WebControls;

namespace NReco.Web.ActionHandlers {

	public class DataSourceHandler : IProvider<ActionContext, IOperation<ActionContext>> {

		public IOperation<ActionContext> Provide(ActionContext context) {
			if (context.Args is ActionDataSource.SelectEventArgs) {
				return new ExecuteSelect();
			} else if (context.Args is ActionDataSource.InsertEventArgs) {
				return new ExecuteInsert();
			} else if (context.Args is ActionDataSource.DeleteEventArgs) {
				return new ExecuteDelete();
			} else if (context.Args is ActionDataSource.UpdateEventArgs) {
				return new ExecuteUpdate();
			}
			return null;
		}

		public class ExecuteSelect : IOperation<ActionContext> {
			public void Execute(ActionContext context) {
				var e = (ActionDataSource.SelectEventArgs)context.Args;
				if (e.DataSourceView != null)
					e.DataSourceView.Select(e.SelectArgs, e.Callback);
			}
		}

		public class ExecuteInsert : IOperation<ActionContext> {
			public void Execute(ActionContext context) {
				var e = (ActionDataSource.InsertEventArgs)context.Args;
				if (e.DataSourceView != null)
					try {
						e.DataSourceView.Insert(e.Values, e.Callback);
					} catch (Exception ex) {
						throw new DataSourceHandlerException(e, ex);
					}
			}
		}

		public class ExecuteDelete : IOperation<ActionContext> {
			public void Execute(ActionContext context) {
				var e = (ActionDataSource.DeleteEventArgs)context.Args;
				if (e.DataSourceView != null)
					try {
						e.DataSourceView.Delete(e.Keys, e.OldValues, e.Callback);
					} catch (Exception ex) {
						throw new DataSourceHandlerException(e, ex);
					}
			}
		}

		public class ExecuteUpdate : IOperation<ActionContext> {
			public void Execute(ActionContext context) {
				var e = (ActionDataSource.UpdateEventArgs)context.Args;
				if (e.DataSourceView != null)
					try {
						e.DataSourceView.Update(e.Keys, e.Values, e.OldValues, e.Callback);
					} catch (Exception ex) {
						throw new DataSourceHandlerException(e, ex);
					}
			}
		}

		[Serializable]
		public class DataSourceHandlerException : Exception {
			public CommandEventArgs Args { get; private set; }

			public DataSourceHandlerException(CommandEventArgs dataSourceArgs, Exception innerEx)
				: base( WebManager.GetLabel( String.Format("Data source {0} failed: {1}", dataSourceArgs.CommandName,innerEx.Message) ), innerEx ) {
				Args = dataSourceArgs;
			}

		}

	}
}
