using System;
using System.Collections;
using System.Text;

namespace NReco.Winter.Converting {
	
	/// <summary>
	/// From NReco IOperation to NI IOperation interface wrapper
	/// </summary>
	public class NiOperationToWrapper : NI.Common.Operations.IOperation {
		IOperation _UnderlyingOperation;

		public IOperation UnderlyingOperation {
			get { return _UnderlyingOperation; }
			set { _UnderlyingOperation = value; }
		}

		public NiOperationToWrapper(IOperation op) {
			_UnderlyingOperation = op;
		}

		public void Execute(IDictionary context) {
			UnderlyingOperation.Execute(context);
		}
	}
}
