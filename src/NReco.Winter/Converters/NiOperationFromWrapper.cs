using System;
using System.Collections;
using System.Text;

using NReco.Converting;

namespace NReco.Winter.Converters {
	
	/// <summary>
	/// NI IOperation to NReco IOperation interface wrapper
	/// </summary>
	public class NiOperationFromWrapper : IOperation {
		NI.Common.Operations.IOperation _UnderlyingOperation;
		string _DefaultContextKey = "arg";

		/// <summary>
		/// Get or set underlying NI IOperation instance
		/// </summary>
		public NI.Common.Operations.IOperation UnderlyingOperation {
			get { return _UnderlyingOperation; }
			set { _UnderlyingOperation = value; }
		}

		/// <summary>
		/// Get or set NI IOperation context key used for non-IDictionary contexts
		/// </summary>
		public string DefaultContextKey {
			get { return _DefaultContextKey; }
			set { _DefaultContextKey = value; }
		}

		public NiOperationFromWrapper(NI.Common.Operations.IOperation niOp) {
			_UnderlyingOperation = niOp;
		}

		public void Execute(object context) {
			IDictionary contextDict = context as IDictionary;
			if (contextDict==null && context!=null) {
				ITypeConverter conv = ConvertManager.FindConverter( context.GetType(), typeof(IDictionary) );
				if (conv!=null)
					contextDict = conv.Convert(context, typeof(IDictionary) ) as IDictionary;
			}
			if (contextDict==null) {
				contextDict = new Hashtable();
				contextDict[DefaultContextKey] = context;
			}
			UnderlyingOperation.Execute(contextDict);
		}

	}
}
