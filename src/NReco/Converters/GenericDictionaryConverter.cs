using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Reflection;

using NReco.Collections;

namespace NReco.Converters {

	/// <summary>
	/// Generic IDictionary converter interface
	/// </summary>
	public class GenericDictionaryConverter : BaseGenericTypeConverter {
		
		protected override bool CanConvertFromGeneric { get { return true; } }
		protected override bool CanConvertToGeneric { get { return true; } }
		protected override Type GenDefIType { get { return typeof(IDictionary<,>); } }
		protected override Type NonGenIType { get { return typeof(IDictionary); } }

		public GenericDictionaryConverter() { }

		protected override object ConvertFromGeneric(object o, Type fromGenIType) {
			return CreateGenericWrapper(typeof(DictionaryWrapper<,>), fromGenIType, o);
		}
		protected override object ConvertToGeneric(object o, Type toGenIType) {
			Type[] dictGArgs = toGenIType.GetGenericArguments();
			IDictionary fromDict = (IDictionary)o;
			Type genDictType = typeof(Dictionary<,>).MakeGenericType(dictGArgs);
			object genDictObj = Activator.CreateInstance(genDictType);
			MethodInfo genDictAddMInfo = genDictType.GetMethod("Add");
			foreach (DictionaryEntry entry in fromDict) {
				genDictAddMInfo.Invoke(genDictObj, new object[] { entry.Key, entry.Value });
			}
			return genDictObj;
		}


	}
}
