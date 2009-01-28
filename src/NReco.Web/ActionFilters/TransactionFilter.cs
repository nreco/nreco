using System;
using System.Collections.Generic;
using System.Text;

using NReco.Operations;

namespace NReco.Web.ActionFilters {
	
	/// <summary>
	/// Transaction filter
	/// </summary>
	/// <remarks>Not thread safe!</remarks>
	public class TransactionFilter : IOperation<ActionFilterContext> {

		public IProvider<ActionContext, bool> Match { get; set; }

		public TransactionOperation<ActionContext> Transaction { get; set; }

		public TransactionFilter() {
		}

		public void Execute(ActionFilterContext context) {
			if (Match != null && !Match.Provide(context.ActionContext))
				return;
			Transaction.UnderlyingOperation = new Chain<ActionContext>(context.Operations);
			context.Operations = new List<IOperation<ActionContext>> { { Transaction } };
		}

	}
}
