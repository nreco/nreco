using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Operations {
	
	public class LazyOperation<Context> : IOperation<Context> {
		IProvider<string, IOperation> _InstanceProvider;
		string _OperationName;

		public string OperationName {
			get { return _OperationName; }
			set { _OperationName = value; }
		}

		public IProvider<string, IOperation> InstanceProvider {
			get { return _InstanceProvider; }
			set { _InstanceProvider = value; }
		}

		public void Execute(Context context) {
			IOperation operation = InstanceProvider.Get(OperationName);
			if (operation==null)
				throw new ArgumentException("Operation instance not found: "+OperationName);
			operation.Execute(context);
		}

		void IOperation.Execute(object context) {
			Execute( (Context)context );
		}

	}
}
