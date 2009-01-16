using System;
using System.Collections.Generic;
using System.Text;

using NI.Common.Providers;

namespace NReco.Winter.Converting {
	
	/// <summary>
	/// From NReco IProvider to NI IObjectProvider interface wrapper
	/// </summary>
	public class NiProviderToWrapper : IObjectProvider {
		IProvider _UnderlyingProvider;

		public IProvider UnderlyingProvider {
			get { return _UnderlyingProvider; }
			set { _UnderlyingProvider = value; }
		}

		public NiProviderToWrapper(IProvider prv) {
			_UnderlyingProvider = prv;
		}

		public object GetObject(object context) {
			return UnderlyingProvider.Provide(context);
		}
	}
}
