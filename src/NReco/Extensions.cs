using System;
using System.Collections.Generic;
using System.Text;

namespace NReco {
	
	public static class Extensions {

		public static T Provide<C,T>(this IProvider<C,T> prv) {
			return prv.Provide( default(C) );
		}

		public static void Execute<C>(this IOperation<C> op) {
			op.Execute(default(C));
		}

	}
}
