using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using NReco.Collections;

namespace NReco.Converting {

	/// <summary>
	/// Context converter.
	/// </summary>
    public class ContextConverter : ITypeConverter
    {

		public ContextConverter() {
		}

		public virtual bool CanConvert(Type fromType, Type toType) {
			if (!typeof(Context).IsAssignableFrom(fromType))
				return false;
			if (toType == typeof(IDictionary) )
				return true;
			if (toType==typeof(IDictionary<string,object>))
				return true;
			return false;
		}

		public virtual object Convert(object o, Type toType) {
			if (o is Context) {
				if (toType == typeof(IDictionary))
					return new DictionaryWrapper<string,object>(
							new ObjectDictionaryWrapper(o) );
				if (toType == typeof(IDictionary<string,object>)) {
					return new ObjectDictionaryWrapper(o);
				}
			}
			throw new InvalidCastException();
		}

	}

}
