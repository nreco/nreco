using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Converters {
	
	public class CompositeTypeConverter : ITypeConverter {
		IList<ITypeConverter> _Converters;

		public IList<ITypeConverter> Converters {
			get { return _Converters; }
			set { _Converters = value; }
		}

		public CompositeTypeConverter() { }

		public CompositeTypeConverter(IList<ITypeConverter> conv) {
			Converters = conv;
		}

		public bool CanConvert(Type fromType, Type toType) {
			foreach (ITypeConverter tConv in Converters)
				if (tConv.CanConvert(fromType,toType))
					return true;
			return false;
		}

		public object Convert(object o, Type toType) {
			foreach (ITypeConverter tConv in Converters)
				if (tConv.CanConvert(o.GetType(), toType))
					return tConv.Convert(o,toType);
			throw new InvalidCastException(
					String.Format("Cannot convert from {0} to {1}",o.GetType().Name,toType.Name));
		}

	}
}
