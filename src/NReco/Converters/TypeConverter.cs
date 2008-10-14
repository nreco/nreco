using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Converters {
	
	/// <summary>
	/// Provides access to default type conversion mechanizm.
	/// </summary>
	public static class TypeConverter {
		static string AppSettingKey = "NReco.Converters.TypeConverter.ListProviderType";
		static IList<ITypeConverter> _Converters;

		static TypeConverter() {
			_Converters = new List<ITypeConverter>();
			// default set
			Converters.Add(new GenericListConverter());
			Converters.Add(new GenericDictionaryConverter());
			Converters.Add(new GenericProviderConverter());
			Converters.Add(new GenericOperationConverter());
			Converters.Add(new GenericCollectionConverter());
		}

		/// <summary>
		/// List of default converters.
		/// </summary>
		public static IList<ITypeConverter> Converters {
			get { return _Converters; }
		}
		
		/// <summary>
		/// Find converter in default converters for given conversion.
		/// </summary>
		/// <param name="fromType">from type</param>
		/// <param name="toType">to type</param>
		/// <returns>type converter that can perform conversion or null</returns>
		public static ITypeConverter FindConverter(Type fromType, Type toType) {
			for (int i=0; i<Converters.Count; i++)
				if (Converters[i].CanConvert(fromType, toType))
					return Converters[i];
			return null;
		}

		public static bool CanConvert(Type fromType, Type toType) {
			return FindConverter(fromType,toType)!=null;
		}

		public static object Convert(object o, Type toType) {
			if (o==null) {
				if (toType.IsValueType) return null;
				throw new InvalidCastException("Cannot convert null to value type");
			}
			ITypeConverter conv = FindConverter(o.GetType(),toType);
			if (conv!=null)
				return conv.Convert(o,toType);
			throw new InvalidCastException(
					String.Format("Cannot convert from {0} to {1}",o.GetType().Name,toType.Name));
		}

	}
}
