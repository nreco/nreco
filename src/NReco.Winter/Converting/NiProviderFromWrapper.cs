using System;
using System.Collections.Generic;
using System.Collections;
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
			object prvContext = context;
			// lets try to convert context to IDictionary b/c this is preferred context in NIC.NET
			if (prvContext != null) {
				var cnv = ConvertManager.FindConverter(prvContext.GetType(), typeof(IDictionary));
				if (cnv != null)
					prvContext = cnv.Convert(prvContext, typeof(IDictionary));
			}

			object res = UnderlyingProvider.GetObject(prvContext);
			if (!(res is R) && res != null) {
				return ConvertManager.ChangeType<R>(res);
			} else {
				return (R)((object)res);
			}
		}

	}
}
