using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Operations {
	
	/// <summary>
	/// Lazy operation proxy
	/// </summary>
	public class LazyOperation: IOperation {
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

		public void Execute(object context) {
			IOperation operation = InstanceProvider.Provide(OperationName);
			if (operation==null)
				throw new ArgumentException("Operation instance not found: "+OperationName);
			operation.Execute(context);
		}

	}


}
