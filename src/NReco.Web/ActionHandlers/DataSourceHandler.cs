using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using NReco.Composition;

namespace NReco.Web.ActionHandlers {

	public class DataSourceHandler : IProvider<ActionContext, IOperation<ActionContext>> {

		public IOperation<ActionContext> Provide(ActionContext context) {
			IOperation<ActionContext> dsOp = null;
			var dsCallbackOp = new ExecuteDataSourceCallback();
			if (context.Args is ActionDataSource.SelectEventArgs) {
				return new ExecuteSelect();
			} else if (context.Args is ActionDataSource.InsertEventArgs) {
				dsOp = new ExecuteInsert(dsCallbackOp);
			} else if (context.Args is ActionDataSource.DeleteEventArgs) {
				dsOp = new ExecuteDelete(dsCallbackOp);
			} else if (context.Args is ActionDataSource.UpdateEventArgs) {
				dsOp = new ExecuteUpdate(dsCallbackOp);
			}
			return new Chain<ActionContext>(new IOperation<ActionContext>[] { dsOp, dsCallbackOp });
		}

		public class ExecuteDataSourceCallback : IOperation<ActionContext>, ControlTreeHandler.IControlOrderedOperation {
			int callbackAffectedRecords;
			Exception callbackException;
			public DataSourceViewOperationCallback OriginalCallback;

			public ControlTreeHandler.ControlOperationOrder Order {
				get { return ControlTreeHandler.ControlOperationOrder.After; }
			}

			public bool InternalCallback(int affectedRecords, Exception ex) {
				callbackAffectedRecords = affectedRecords;
				callbackException = ex;
				return ex == null;
			}

			public void Execute(ActionContext context) {
				OriginalCallback(callbackAffectedRecords, callbackException);
			}

		}

		public class ExecuteSelect : IOperation<ActionContext> {

			public void Execute(ActionContext context) {
				var e = (ActionDataSource.SelectEventArgs)context.Args;
				if (e.DataSourceView != null)
					e.DataSourceView.Select(e.SelectArgs, e.Callback);
			}
		}

		public class ExecuteInsert : IOperation<ActionContext> {
			ExecuteDataSourceCallback CallbackOperation;

			public ExecuteInsert(ExecuteDataSourceCallback callbackOp) {
				CallbackOperation = callbackOp;
			}

			public void Execute(ActionContext context) {
				var e = (ActionDataSource.InsertEventArgs)context.Args;
				if (e.DataSourceView != null)
					try {
						CallbackOperation.OriginalCallback = e.Callback;
						e.DataSourceView.Insert(e.Values, new DataSourceViewOperationCallback(CallbackOperation.InternalCallback) );
					} catch (Exception ex) {
						throw new DataSourceHandlerException(e, ex);
					}
			}
		}

		public class ExecuteDelete : IOperation<ActionContext> {
			ExecuteDataSourceCallback CallbackOperation;

			public ExecuteDelete(ExecuteDataSourceCallback callbackOp) {
				CallbackOperation = callbackOp;
			}

			public void Execute(ActionContext context) {
				var e = (ActionDataSource.DeleteEventArgs)context.Args;
				if (e.DataSourceView != null)
					try {
						CallbackOperation.OriginalCallback = e.Callback;
						e.DataSourceView.Delete(e.Keys, e.OldValues, new DataSourceViewOperationCallback(CallbackOperation.InternalCallback));
					} catch (Exception ex) {
						throw new DataSourceHandlerException(e, ex);
					}
			}
		}

		public class ExecuteUpdate : IOperation<ActionContext> {
			ExecuteDataSourceCallback CallbackOperation;

			public ExecuteUpdate(ExecuteDataSourceCallback callbackOp) {
				CallbackOperation = callbackOp;
			}

			public void Execute(ActionContext context) {
				var e = (ActionDataSource.UpdateEventArgs)context.Args;
				if (e.DataSourceView != null)
					try {
						CallbackOperation.OriginalCallback = e.Callback;
						e.DataSourceView.Update(e.Keys, e.Values, e.OldValues, new DataSourceViewOperationCallback(CallbackOperation.InternalCallback));
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
