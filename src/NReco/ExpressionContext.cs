using System;
using System.Collections.Generic;
using System.Text;

namespace NReco {

	public class ExpressionContext<ExprT> : Context {
		ExprT _Expression;
		NameValueContext _Variables;

		public ExprT Expression {
			get { return _Expression; }
		}
		public NameValueContext Variables {
			get { return _Variables; }
		}

		public ExpressionContext(ExprT expr, NameValueContext vars) {
			_Expression = expr;
			_Variables = vars;
		}
	}

}
