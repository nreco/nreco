using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NReco.Linq {
	
	public class LambdaParserException : Exception {

		public string Expression { get; private set; }

		public int Index { get; private set; }

		public LambdaParserException(string expr, int idx, string msg)
			: base( String.Format("{0} at {1}: {2}", msg, idx, expr) ) {
			Expression = expr;
			Index = idx;
		}
	}
}
