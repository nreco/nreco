using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using NI.Ioc;
using NReco.Converting;

namespace NReco.Application.Ioc {
	
	public class ComponentFactory : NI.Ioc.ComponentFactory {

		public ComponentFactory(IComponentFactoryConfiguration config)
			: base(config) {
		}

		protected override object ConvertTo(object o, Type toType) {
			if (toType == null || toType == typeof(object))
				return o;

			if (o != null) {
				ITypeConverter cnv = ConvertManager.FindConverter(o.GetType(), toType);
				if (cnv != null)
					return cnv.Convert(o, toType);
			} else {
				if (!toType.IsValueType)
					return null;
			}
			return base.ConvertTo(o, toType);
		}
	}
}
