using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Operations {

	public class InvokeContext : Context {
		object _Result = null;
		object _Context = null;

		/// <summary>
		/// Invoke result
		/// </summary>
		public object Result {
			get { return _Result; }
			set { _Result = value; }
		}

		public object Context {
			get { return _Context; }
		}

		public InvokeContext(object context) {
			_Context = context;
		}
	}

}
