using System;
using System.Collections.Generic;
using System.Text;

using NI.Winter;
using NReco.Converters;

namespace NReco.Winter {
	
	public class ServiceProvider : NI.Winter.ServiceProvider {

		public ServiceProvider() : base() {
			CreateValueFactory();
		}

		public ServiceProvider(IComponentsConfig config) : base() {
			CreateValueFactory();
			Config = config;
		}

		public ServiceProvider(IComponentsConfig config, bool countersEnabled) : base() {
			CreateValueFactory();
			CountersEnabled = countersEnabled;
			Config = config;
		}

		protected void CreateValueFactory() {
			ValueFactory = new NReco.Winter.LocalValueFactory(this);
		}

	}
}
