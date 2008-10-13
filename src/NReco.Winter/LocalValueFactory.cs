using System;
using System.Collections.Generic;
using System.Text;

using NReco;
using NI.Winter;

namespace NReco.Winter {
	
	public class LocalValueFactory : ServiceProvider.LocalValueFactory {
		
		ITypeConverter _TypeConverter = null;

		public ITypeConverter TypeConverter {
			get { return _TypeConverter; }
			set { _TypeConverter = value; }
		}

		public LocalValueFactory(ServiceProvider srvPrv) : base(srvPrv) {
		}

		public LocalValueFactory(ServiceProvider srvPrv, ITypeConverter typeCnv) : base(srvPrv) {
			TypeConverter = typeCnv;
		}

		protected override object ConvertTo(object o, Type toType) {
			if (TypeConverter!=null && o!=null && TypeConverter.CanConvert(o.GetType(),toType))
				return TypeConverter.Convert(o,toType);
			return base.ConvertTo(o, toType);
		}

	}
}
