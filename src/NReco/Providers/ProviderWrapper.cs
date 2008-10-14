using System;
using System.Collections.Generic;
using System.Text;
using NReco.Converters;

namespace NReco.Providers {
	
	/// <summary>
	/// Provider wrapper between generic and non-generic interfaces
	/// </summary>
	/// <typeparam name="Context"></typeparam>
	/// <typeparam name="Result"></typeparam>
	public class ProviderWrapper<ContextT,ResT> : IProvider {
		IProvider<ContextT,ResT> _UnderlyingProvider;

		public IProvider<ContextT,ResT> UnderlyingProvider {
			get { return _UnderlyingProvider; }
			set { _UnderlyingProvider = value; }
		}

		public ProviderWrapper() {}

		public ProviderWrapper(IProvider<ContextT,ResT> underlyingPrv) {
			UnderlyingProvider = underlyingPrv;
		}

		public object Provide(object context) {
			if (!(context is ContextT) && context != null) {
				context = TypeConverter.Convert(context, typeof(ContextT));
			}

			object res = UnderlyingProvider.Provide( (ContextT) context);
			return res;
		}

	}
}
