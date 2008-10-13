using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using NReco.Collections;

namespace NReco.Converters {

	/// <summary>
	/// Generic ICollection convertor interface
	/// </summary>
	public class GenericCollectionConverter : GenericTypeConverter {
		
		protected override bool CanConvertFromGeneric { get { return true; } }
		protected override bool CanConvertToGeneric { get { return true; } }
		protected override Type GenDefIType { get { return typeof(ICollection<>); } }
		protected override Type NonGenIType { get { return typeof(ICollection); } }

		public GenericCollectionConverter() { }

		protected override object ConvertFromGeneric(object o, Type fromGenIType) {
			return CreateGenericWrapper(typeof(CollectionWrapper<>), fromGenIType, o);
		}
		protected override object ConvertToGeneric(object o, Type toGenIType) {
			Type[] collGArgs = toGenIType.GetGenericArguments();
			ICollection fromColl = (ICollection)o;
			Array fromArr = Array.CreateInstance( collGArgs[0], fromColl.Count);
			fromColl.CopyTo(fromArr,0);
			return fromArr; // typed array implements ICollection<>
		}


	}
}
