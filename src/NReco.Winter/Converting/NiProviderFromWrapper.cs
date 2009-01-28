using System;
using System.Collections.Generic;
using System.Text;
using NReco.Converting;
using NI.Common.Providers;

namespace NReco.Winter.Converting {
	
	/// <summary>
	/// From NI IObjectProvider to NReco IProvider interface wrapper
	/// </summary>
	public class NiProviderFromWrapper<C,R> : IProvider<C,R> {

		public IObjectProvider UnderlyingProvider { get; set; }

		public NiProviderFromWrapper(IObjectProvider niPrv) {
			UnderlyingProvider = niPrv;
		}

		public R Provide(C context) {
			object res = UnderlyingProvider.GetObject(context);
			if (!(res is R) && res != null) {
				return ConvertManager.ChangeType<R>(res);
			} else {
				return (R)((object)res);
			}
		}

	}
}
