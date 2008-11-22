using System;
using System.Collections;
using System.Text;

using NReco.Converters;

namespace NReco.Winter.Converters {
	
	public class NiOperationConverter : BaseTypeConverter<NI.Common.Operations.IOperation,IOperation,NiOperationFromWrapper,NiOperationToWrapper> {

		public NiOperationConverter() {
		}

		public override bool CanConvert(Type fromType, Type toType) {
			if (CanConvert(fromType,toType))
				return true;

			return false;
		}

		public override object Convert(object o, Type toType) {
			if (base.CanConvert(o.GetType(),toType))
				return base.Convert(o, toType);
			return null;
		}

	}
}
