using System;
using System.Collections.Generic;
using System.Text;
using NReco.Converters;

namespace NReco.Providers {
	
	/// <summary>
	/// Provider wrapper between abstract and generic interfaces
	/// </summary>
	/// <typeparam name="Context"></typeparam>
	/// <typeparam name="Result"></typeparam>
	public class ProviderWrapper<Context,ResT> : IProvider<Context,ResT> {
		IProvider _UnderlyingProvider;
		ITypeConverter _TypeConverter = null;

		public ITypeConverter TypeConverter {
			get { return _TypeConverter; }
			set { _TypeConverter = value; }
		}

		public IProvider UnderlyingProvider {
			get { return _UnderlyingProvider; }
			set { _UnderlyingProvider = value; }
		}

		public ProviderWrapper() {}

		public ProviderWrapper(IProvider underlyingPrv) {
			UnderlyingProvider = underlyingPrv;
		}

		public ResT Get(Context context) {
			object res = UnderlyingProvider.Get(context);
			if (res is ResT) return (ResT)res;
			if (res==null)
				return typeof(ResT).IsValueType ? default(ResT) : (ResT)res;
			if (TypeConverter!=null && TypeConverter.CanConvert(res.GetType(),typeof(ResT)))
				return (ResT)TypeConverter.Convert(res,typeof(ResT));
			throw new InvalidCastException();
		}

		object IProvider.Get(object context) {
			return Get( (Context)context );
		}

	}
}
