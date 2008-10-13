using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Providers {
	
	public class ContextProvider : IProvider {
		public readonly static ContextProvider Instance = new ContextProvider();

		public ContextProvider() {}

		public object Provide(object context) {
			return context;
		}
	}
}
