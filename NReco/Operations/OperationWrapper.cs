using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Operations {
	
	/// <summary>
	/// Operation wrapper between generic and non-generic operation interfaces
	/// </summary>
	/// <typeparam name="Context">context type</typeparam>
	public class OperationWrapper<ContextT> : IOperation {
		IOperation<ContextT> _UnderlyingOperation;
		ITypeConverter _TypeConverter = null;

		public ITypeConverter TypeConverter {
			get { return _TypeConverter; }
			set { _TypeConverter = value; }
		}

		public IOperation<ContextT> UnderlyingOperation {
			get { return _UnderlyingOperation; }
			set { _UnderlyingOperation = value; }
		}

		public OperationWrapper() { }

		public OperationWrapper(IOperation<ContextT> op) {
			UnderlyingOperation = op;
		}

		public void Execute(object context) {
			if (!(context is ContextT) && context!=null && TypeConverter != null) {
				if (TypeConverter.CanConvert(context.GetType(), typeof(ContextT)))
					context = TypeConverter.Convert(context, typeof(ContextT));
			}
			UnderlyingOperation.Execute( (ContextT)context);
		}

	}


}
