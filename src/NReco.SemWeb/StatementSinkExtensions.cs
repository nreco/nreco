using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SemWeb;

namespace NReco.SemWeb {

	public static class StatementSinkExtensions {

		public static bool AddLabel(this StatementSink sink, Entity subject, string label) {
			return sink.Add(
					new Statement( subject, NS.Rdfs.labelEntity, new Literal(label) )
				);
		}


	}


}
