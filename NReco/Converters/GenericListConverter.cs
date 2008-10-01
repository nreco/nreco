using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using NReco.Collections;

namespace NReco.Converters {

	/// <summary>
	/// Generic IList convertor interface
	/// </summary>
	public class GenericListConverter : GenericTypeConverter {
		
		protected override bool CanConvertFromGeneric { get { return true; } }
		protected override bool CanConvertToGeneric { get { return true; } }
		protected override Type GenDefIType { get { return typeof(IList<>); } }
		protected override Type NonGenIType { get { return typeof(IList); } }

		public GenericListConverter() { }

		public override bool CanConvert(Type fromType, Type toType) {
			// check also conversion to arrays
			//TBD!
			/*if (fromType.IsGenericType && toType.IsArray) {
				Type gIType = FindGenericInterface(fromType,GenDefIType);

			}*/

			return base.CanConvert(fromType,toType);
		}

		protected override object ConvertFromGeneric(object o, Type fromGenIType) {
			return CreateGenericWrapper(typeof(ListWrapper<>), fromGenIType, o);
		}
		protected override object ConvertToGeneric(object o, Type toGenIType) {
			Type[] listGArgs = toGenIType.GetGenericArguments();
			IList fromList = (IList)o;
			Array fromArr = Array.CreateInstance( listGArgs[0], fromList.Count);
			fromList.CopyTo(fromArr,0);
			Type genListType = typeof(List<>).MakeGenericType(listGArgs);
			return Activator.CreateInstance(genListType, fromArr);
		}


	}
}
