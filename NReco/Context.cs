using System;
using System.Collections.Generic;
using System.Text;

namespace NReco {
	
	/// <summary>
	/// Context is a base class for classes containing typed context data.
	/// </summary>
	public class Context {
		
		public readonly static Context Empty = new Context();

		public Context() {
		}
	}
}
