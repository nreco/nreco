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

		protected bool IsObjectProviderCompatible(Type t) {
			return t==typeof(IObjectListProvider) || t==typeof(IStringListProvider);
		}

		public override object Convert(object o, Type toType) {
			if (TypeHelper.IsDelegate(toType) && toType.GetMethod("Invoke").GetParameters().Length==1) {
				var objPrvWrapper = Convert(o, typeof(IProvider<object, object>));
				return new DelegateConverter().Convert( objPrvWrapper, toType );
			}
			
			if (IsObjectProviderCompatible(toType))
				return base.Convert(o, typeof(IObjectProvider));
			return base.Convert(o, toType);
		}

		public override bool CanConvert(Type fromType, Type toType) {
			if (TypeHelper.IsDelegate(toType)) {
				var delegMethod = toType.GetMethod("Invoke");
				if (delegMethod.GetParameters().Length == 1) {
					return CanConvert( fromType, typeof(IProvider<object,object>) );
				}
			}

			if (IsObjectProviderCompatible(toType))
				return base.CanConvert(fromType, typeof(IObjectProvider));
			return base.CanConvert(fromType, toType);
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
