using System;
using System.Collections.Generic;
using System.Text;

using NI.Winter;
using NReco.Converters;

namespace NReco.Winter {
	
	public class ServiceProvider : NI.Winter.ServiceProvider {

		public ServiceProvider() {
		}

		public ServiceProvider(IComponentsConfig config) : base(config) {
		}

		public ServiceProvider(IComponentsConfig config, bool countersEnabled) : base(config,countersEnabled) {

		}

		protected void CreateValueFactory() {
			ValueFactory = new LocalValueFactory(this);
		}

	}
}
