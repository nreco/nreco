using System;
using System.Collections.Generic;
using System.Text;

using NReco;
using NReco.Converters;
using NI.Winter;

namespace NReco.Winter {
	
	public class LocalValueFactory : ServiceProvider.LocalValueFactory {
		
		ITypeConverter _Converter = null;

		public ITypeConverter Converter {
			get { return _Converter; }
			set { _Converter = value; }
		}

		public LocalValueFactory(ServiceProvider srvPrv) : base(srvPrv) {
		}

		public LocalValueFactory(ServiceProvider srvPrv, ITypeConverter typeCnv) : base(srvPrv) {
			Converter = typeCnv;
		}

		protected override object ConvertTo(object o, Type toType) {
			if (Converter!=null && o!=null && Converter.CanConvert(o.GetType(),toType))
				return Converter.Convert(o,toType);
			if (o!=null) {
				ITypeConverter cnv = TypeConverter.FindConverter(o.GetType(),toType);
				if (cnv!=null)
					return cnv.Convert(o,toType);
			} else {
				if (!toType.IsValueType)
					return null;
			}
			return base.ConvertTo(o, toType);
		}

	}
}
