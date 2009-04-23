using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SemWeb;

namespace NReco.SemWeb {
	
	public static class SelectableSourceExtensions {
		
		public static Statement SelectSingle(this SelectableSource src, Statement tpl) {
			var sink = new FirstStatementSink();
			src.Select(tpl, sink);
			return sink.First;
		}

		public static Statement SelectSingle(this SelectableSource src, SelectFilter filter) {
			var sink = new FirstStatementSink();
			src.Select(filter, sink);
			return sink.First;
		}

		public static Literal SelectLiteral(this SelectableSource src, Statement tpl) {
			var st = SelectSingle(src, tpl);
			if (st != null && st.Object is Literal)
				return (Literal)st.Object;
			return null;
		}

		internal class FirstStatementSink : StatementSink {
			public Statement First { get; private set; }

			public bool Add(Statement st) {
				if (First == null) {
					First = st;
					return true;
				} else
					return false;
			}
		}

	}


}
