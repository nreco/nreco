using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Providers {
	
	/// <summary>
	/// Const value provider
	/// </summary>
	/// <typeparam name="ResT">provider result type</typeparam>
	public class ConstProvider<ResT> : IProvider<object,ResT> {
		ResT _Value = default(ResT);

		public ResT Value {
			get { return _Value; }
			set { _Value = value; }
		}

		public ConstProvider() { }

		public ConstProvider(ResT constValue) {
			Value = constValue;
		}


		public ResT Provide(object context) {
			return Value;
		}

	}

	public class ConstProvider : ConstProvider<object>, IProvider {
		public ConstProvider() { }
		public ConstProvider(object o) {
			Value = o;
		}
	}

}
