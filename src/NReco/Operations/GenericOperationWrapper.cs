using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Operations {
	
	/// <summary>
	/// Operation wrapper between non-generic and generic operation interfaces
	/// </summary>
	/// <typeparam name="Context">context type</typeparam>
	public class GenericOperationWrapper<ContextT> : IOperation<ContextT> {
		IOperation _UnderlyingOperation;

		public IOperation UnderlyingOperation {
			get { return _UnderlyingOperation; }
			set { _UnderlyingOperation = value; }
		}

		public GenericOperationWrapper() { }

		public GenericOperationWrapper(IOperation op) {
			UnderlyingOperation = op;
		}

		public void Execute(ContextT context) {
			UnderlyingOperation.Execute(context);
		}

	}


}
