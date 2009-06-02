using System;
using System.Collections.Generic;
using System.Text;

using NReco.Composition;
using NReco.Web.ActionHandlers;

namespace NReco.Web.ActionFilters {
	
	/// <summary>
	/// Control tree handlers order filter
	/// </summary>
	public class ControlHandlerOrderFilter : IOperation<ActionFilterContext> {

		public ControlHandlerOrderFilter() {
		}

		protected void AddOperation(
						IList<IOperation<ActionContext>> beforeList,
						IList<IOperation<ActionContext>> normList,
						IList<IOperation<ActionContext>> afterList,
						IOperation<ActionContext> op) {
			if (op is Chain<ActionContext>) {
				var chain = (Chain<ActionContext>)op;
				foreach (var chainOp in chain.Operations)
					AddOperation(beforeList, normList, afterList, chainOp);
				return;
			}
			if (op is ControlTreeHandler.ControlOperation) {
				var ctrlOp = (ControlTreeHandler.ControlOperation)op;
				switch (ctrlOp.Order) {
					case ControlTreeHandler.ControlOperationOrder.Before:
						beforeList.Add(ctrlOp);
						break;
					case ControlTreeHandler.ControlOperationOrder.Normal:
						normList.Add(ctrlOp);
						break;
					case ControlTreeHandler.ControlOperationOrder.After:
						afterList.Add(ctrlOp);
						break;
				}
			}
			else {
				normList.Add(op);
			}
		}

		public void Execute(ActionFilterContext context) {
			var beforeList = new List<IOperation<ActionContext>>();
			var normList = new List<IOperation<ActionContext>>();
			var afterList = new List<IOperation<ActionContext>>();
			// extract control operations

			for (int i = 0; i < context.Operations.Count; i++) {
				AddOperation(beforeList, normList, afterList, context.Operations[i]);
			}
			if (beforeList.Count == 0 && afterList.Count == 0) 
				return;
			var resList = new List<IOperation<ActionContext>>(context.Operations.Count);
			resList.AddRange(beforeList);
			resList.AddRange(normList);
			resList.AddRange(afterList);
			context.Operations = resList;
		}

	}
}
