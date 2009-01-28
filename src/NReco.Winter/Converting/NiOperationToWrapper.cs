using System;
using System.Collections;
using System.Text;

using NReco.Converting;

namespace NReco.Winter.Converting {
	
	/// <summary>
	/// From NReco IOperation to NI IOperation interface wrapper
	/// </summary>
	public class NiOperationToWrapper<C> : NI.Common.Operations.IOperation {

		public IOperation<C> UnderlyingOperation { get; set; }

		public NiOperationToWrapper(IOperation<C> op) {
			UnderlyingOperation = op;
		}

		public void Execute(IDictionary context) {
			C c;
			if (!(context is C) && context != null) {
				c = ConvertManager.ChangeType<C>(context);
			}
			else {
				c = (C)((object)context);
			}
			UnderlyingOperation.Execute(c);
		}
	}
}
