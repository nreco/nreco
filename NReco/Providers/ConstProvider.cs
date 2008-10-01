using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Providers {
	
	/// <summary>
	/// Const value provider
	/// </summary>
	/// <typeparam name="ResT">provider result type</typeparam>
	public class ConstProvider<ResT> : IProvider<Context,ResT> {
		ResT _Value;

		public ResT Value {
			get { return _Value; }
			set { _Value = value; }
		}

		public ConstProvider() { }

		public ConstProvider(ResT constValue) {
			Value = constValue;
		}


		public ResT Get(Context context) {
			return Value;
		}

		public object Get(object context) {
			return Get(Context.Empty);
		}

	}
}
