using System;
using System.Collections;
using System.Text;

using NReco.Converting;
using INIOperation = NI.Common.Operations.IOperation;

namespace NReco.Winter.Converting {
	
	public class NiOperationConverter : BaseTypeConverter<NI.Common.Operations.IOperation,IOperation,NiOperationFromWrapper,NiOperationToWrapper> {

		public NiOperationConverter() {
		}

		public override bool CanConvert(Type fromType, Type toType) {
			if (base.CanConvert(fromType,toType))
				return true;

			if (fromType.GetInterface(typeof(INIOperation).FullName) == typeof(INIOperation)) {
				// may be conversion from IOperation to toType exists?
				return ConvertManager.CanConvert(typeof(INIOperation), toType);
			}

			return false;
		}

		public override object Convert(object o, Type toType) {
			if (base.CanConvert(o.GetType(),toType))
				return base.Convert(o, toType);

			if (o is INIOperation) {
				ITypeConverter conv = ConvertManager.FindConverter(typeof(IOperation), toType);
				if (conv != null) {
					object op = base.Convert(o, typeof(IOperation));
					return conv.Convert(op, toType);
				}
			}

			throw new InvalidCastException();
		}

	}
}
