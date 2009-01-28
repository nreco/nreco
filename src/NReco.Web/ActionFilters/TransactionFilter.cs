using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Web.ActionFilters {
	
	public class TransactionFilter : IProvider<IList<IOperation<ActionContext>>,IList<IOperation<ActionContext>>> {
		public TransactionFilter() {
		}

		public IList<IOperation<ActionContext>> Provide(IList<IOperation<ActionContext>> context) {
			return null;
		}

	}
}
