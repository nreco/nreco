using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Providers {
	
	/// <summary>
	/// Operation wrapper between abstract and generic operation interfaces
	/// </summary>
	/// <typeparam name="Context">context type</typeparam>
	public class OperationWrapper<Context> : IOperation<Context> {
		IOperation _UnderlyingOperation;

		public IOperation UnderlyingOperation {
			get { return _UnderlyingOperation; }
			set { _UnderlyingOperation = value; }
		}

		public void Execute(Context context) {
			UnderlyingOperation.Execute(context);
		}

		void IOperation.Execute(object context) {
			Execute( (Context)context );
		}

	}
}
