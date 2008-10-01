using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Converters {

	public interface ITypeConverter {
		bool CanConvert(Type fromType, Type toType);
		object Convert(object o, Type toType);
	}
}
