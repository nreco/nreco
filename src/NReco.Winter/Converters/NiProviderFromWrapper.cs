using System;
using System.Collections.Generic;
using System.Text;

using NI.Common.Providers;

namespace NReco.Winter.Converters {
	
	/// <summary>
	/// From NI IObjectProvider to NReco IProvider interface wrapper
	/// </summary>
	public class NiProviderFromWrapper : IProvider {
		IObjectProvider _UnderlyingProvider;

		public IObjectProvider UnderlyingProvider {
			get { return _UnderlyingProvider; }
			set { _UnderlyingProvider = value; }
		}

		public NiProviderFromWrapper(IObjectProvider niPrv) {
			_UnderlyingProvider = niPrv;
		}

		public object Provide(object context) {
			return UnderlyingProvider.GetObject(context);
		}

	}
}
