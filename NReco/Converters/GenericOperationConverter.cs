using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Reflection;

using NReco.Collections;
using NReco.Operations;

namespace NReco.Converters {

	/// <summary>
	/// Provider interfaces converter
	/// </summary>
	public class GenericOperationConverter : GenericTypeConverter {
		
		protected override bool CanConvertFromGeneric { get { return true; } }
		protected override bool CanConvertToGeneric { get { return true; } }
		protected override Type GenDefIType { get { return typeof(IOperation<>); } }
		protected override Type NonGenIType { get { return typeof(IOperation); } }

		public GenericOperationConverter() { }

		protected override object ConvertFromGeneric(object o, Type fromGenIType) {
			Type[] prvGArgs = fromGenIType.GetGenericArguments();
			Type prvType = typeof(OperationWrapper<>).MakeGenericType(prvGArgs);
			return Activator.CreateInstance(prvType, new object[] { o });
		}
		protected override object ConvertToGeneric(object o, Type toGenIType) {
			Type[] prvGArgs = toGenIType.GetGenericArguments();
			Type genPrvType = typeof(GenericOperationWrapper<>).MakeGenericType(prvGArgs);
			return Activator.CreateInstance(genPrvType, new object[] { o });
		}

		protected override bool IsCompatibleGArg(int idx, Type fromType, Type toType) {
			return idx==0 && fromType.IsAssignableFrom(toType);
		}

	}
}
