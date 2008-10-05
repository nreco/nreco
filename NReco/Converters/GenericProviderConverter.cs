using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Reflection;

using NReco.Collections;
using NReco.Providers;

namespace NReco.Converters {

	/// <summary>
	/// Generic IProvider converter interface
	/// </summary>
	public class GenericProviderConverter : GenericTypeConverter {
		
		protected override bool CanConvertFromGeneric { get { return false; } }
		protected override bool CanConvertToGeneric { get { return true; } }
		protected override Type GenDefIType { get { return typeof(IProvider<,>); } }
		protected override Type NonGenIType { get { return typeof(IProvider); } }

		public GenericProviderConverter() { }

		protected override object ConvertFromGeneric(object o, Type fromGenIType) {
			return o;
		}
		protected override object ConvertToGeneric(object o, Type toGenIType) {
			Type[] prvGArgs = toGenIType.GetGenericArguments();
			IProvider fromPrv = (IProvider)o;
			Type genPrvType = typeof(ProviderWrapper<,>).MakeGenericType(prvGArgs);
			return Activator.CreateInstance(genPrvType, new object[] { o });
		}


	}
}
