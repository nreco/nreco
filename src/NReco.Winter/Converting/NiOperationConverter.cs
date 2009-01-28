using System;
using System.Collections;
using System.Text;

using NReco.Converting;
using INIOperation = NI.Common.Operations.IOperation;

namespace NReco.Winter.Converting {
	
	public class NiOperationConverter : BaseGenericTypeConverter {
		
		protected override bool CanConvertFromGeneric { get { return true; } }
		protected override bool CanConvertToGeneric { get { return true; } }
		protected override Type GenDefIType { get { return typeof(IOperation<>); } }
		protected override Type NonGenIType { get { return typeof(INIOperation); } }

		public NiOperationConverter() {
		}

		protected override object ConvertFromGeneric(object o, Type fromGenIType) {
			return CreateGenericWrapper(typeof(NiProviderToWrapper<,>), fromGenIType, o);
		}
		protected override object ConvertToGeneric(object o, Type toGenIType) {
			Type genPrvType = typeof(NiProviderFromWrapper<,>).MakeGenericType( toGenIType.GetGenericArguments() );
			return Activator.CreateInstance(genPrvType, new object[] { o });
		}

	}
}
