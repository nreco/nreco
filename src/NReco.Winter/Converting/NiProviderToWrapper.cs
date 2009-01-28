using System;
using System.Collections.Generic;
using System.Text;

using NI.Common.Providers;
using NReco.Converting;

namespace NReco.Winter.Converting {
	
	/// <summary>
	/// From NReco IProvider to NI IObjectProvider interface wrapper
	/// </summary>
	public class NiProviderToWrapper<C,T> : IObjectProvider {

		public IProvider<C, T> UnderlyingProvider { get; set; }

		public NiProviderToWrapper(IProvider<C,T> prv) {
			UnderlyingProvider = prv;
		}

		public object GetObject(object context) {
			C c;
			if (!(context is C) && context != null) {
				c = ConvertManager.ChangeType<C>(context);
			}
			else {
				c = (C)((object)context);
			}

			return UnderlyingProvider.Provide(c);
		}
	}
}
