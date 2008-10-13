using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Reflection;

using NReco.Collections;
using NReco.Providers;

namespace NReco.Converters {

	/// <summary>
	/// Provider interfaces convert
	/// </summary>
	public class GenericProviderConverter : GenericTypeConverter {
		
		protected override bool CanConvertFromGeneric { get { return true; } }
		protected override bool CanConvertToGeneric { get { return true; } }
		protected override Type GenDefIType { get { return typeof(IProvider<,>); } }
		protected override Type NonGenIType { get { return typeof(IProvider); } }

		public GenericProviderConverter() { }

		protected override object ConvertFromGeneric(object o, Type fromGenIType) {
			Type[] prvGArgs = fromGenIType.GetGenericArguments();
			Type prvType = typeof(ProviderWrapper<,>).MakeGenericType(prvGArgs);
			return Activator.CreateInstance(prvType, new object[] { o });
		}
		protected override object ConvertToGeneric(object o, Type toGenIType) {
			Type[] prvGArgs = toGenIType.GetGenericArguments();
			IProvider fromPrv = (IProvider)o;
			Type genPrvType = typeof(GenericProviderWrapper<,>).MakeGenericType(prvGArgs);
			return Activator.CreateInstance(genPrvType, new object[] { o });
		}

		protected override bool IsCompatibleGArg(int idx, Type fromType, Type toType) {
			return (idx == 0 && fromType.IsAssignableFrom(toType)) ||
					(idx==1 && toType.IsAssignableFrom(fromType) );
		}


	}
}
