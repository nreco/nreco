using System;
using System.Collections.Generic;
using System.Text;

namespace NReco.Converting {

	/// <summary>
	/// Special context converter between instances derived from Context class and generic/non-generic dictionaries.
	/// </summary>
    public class ContextConverter : ITypeConverter 
    {

		public ContextConverter() {
		}

		protected bool IsConversion(Type fromType, Type toType, Type t1, Type t2) {
			return  fromType.GetInterface(t1.FullName)==t1 &&
					toType==t2;
		}

		public virtual bool CanConvert(Type fromType, Type toType) {
			if (IsConversion(fromType,toType, typeof(T1), typeof(T2) ))
				return true;
			if (IsConversion(fromType,toType, typeof(T2), typeof(T1) ))
				return true;
			return false;
		}

		public virtual object Convert(object o, Type toType) {
			if (IsConversion(o.GetType(),toType, typeof(T1), typeof(T2) ))
				return Activator.CreateInstance( typeof(DirectWr), new object[] { o } );
			if (IsConversion(o.GetType(),toType, typeof(T2), typeof(T1) ))
				return Activator.CreateInstance( typeof(ReverseWr), new object[] { o } );
			throw new InvalidCastException();
		}

	}

}
