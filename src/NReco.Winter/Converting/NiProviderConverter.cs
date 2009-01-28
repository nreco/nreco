using System;
using System.Collections.Generic;
using System.Text;

using NReco.Converting;
using NI.Common.Providers;

namespace NReco.Winter.Converting {
	
	public class NiProviderConverter : BaseGenericTypeConverter {

		protected override bool CanConvertFromGeneric { get { return true; } }
		protected override bool CanConvertToGeneric { get { return true; } }
		protected override Type GenDefIType { get { return typeof(IProvider<,>); } }
		protected override Type NonGenIType { get { return typeof(IObjectProvider); } }

		public NiProviderConverter() {
		}

		protected override object ConvertFromGeneric(object o, Type fromGenIType) {
			return CreateGenericWrapper(typeof(NiProviderToWrapper<,>), fromGenIType, o);
		}
		protected override object ConvertToGeneric(object o, Type toGenIType) {
			Type genPrvType = typeof(NiProviderFromWrapper<,>).MakeGenericType(toGenIType.GetGenericArguments());
			return Activator.CreateInstance(genPrvType, new object[] { o });
		}


	}
}
