using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using NReco.Converting;
using NReco.Functions;

namespace NReco.Linq {

	public class LambdaParameterWrapper {
		object _Value;

		public object Value {
			get { return _Value; }
		}

		public LambdaParameterWrapper(object val) {
			if (val is LambdaParameterWrapper)
				_Value = ((LambdaParameterWrapper)val).Value; // prevent nested wrappers
			else
				_Value = val;
		}

		public static LambdaParameterWrapper InvokeMethod(object obj, string methodName, object[] args) {
			var argsResolved = new object[args.Length];
			for (int i = 0; i < args.Length; i++)
				argsResolved[i] = args[i] is LambdaParameterWrapper ? ((LambdaParameterWrapper)args[i]).Value : args[i];

			if (obj is LambdaParameterWrapper)
				obj = ((LambdaParameterWrapper)obj).Value;

			var invoke = new InvokeMethod(obj, methodName);
			var res = invoke.Invoke(argsResolved);
			return new LambdaParameterWrapper(res);
		}

		public static LambdaParameterWrapper InvokePropertyOrField(object obj, string propertyName) {
			if (obj == null)
				throw new NullReferenceException(String.Format("Property or field {0}", propertyName));
			if (obj is LambdaParameterWrapper)
				obj = ((LambdaParameterWrapper)obj).Value;

			var prop = obj.GetType().GetProperty(propertyName);
			if (prop != null) {
				var propVal = prop.GetValue(obj, null);
				return new LambdaParameterWrapper(propVal);
			}
			var fld = obj.GetType().GetField(propertyName);
			if (fld != null) {
				var fldVal = fld.GetValue(obj);
				return new LambdaParameterWrapper(fldVal);
			}
			throw new MissingMemberException(obj.GetType().ToString(), propertyName);
		}

		public static LambdaParameterWrapper operator +(LambdaParameterWrapper c1, LambdaParameterWrapper c2) {
			if (c1.Value is string || c2.Value is string) {
				return new LambdaParameterWrapper( Convert.ToString(c1.Value) + Convert.ToString(c2.Value));
			} else {
				var c1decimal = ConvertManager.ChangeType<decimal>(c1.Value);
				var c2decimal = ConvertManager.ChangeType<decimal>(c2.Value);
				return new LambdaParameterWrapper(c1decimal + c2decimal);
			}
		}

		public static LambdaParameterWrapper operator -(LambdaParameterWrapper c1, LambdaParameterWrapper c2) {
			var c1decimal = ConvertManager.ChangeType<decimal>(c1.Value);
			var c2decimal = ConvertManager.ChangeType<decimal>(c2.Value);
			return new LambdaParameterWrapper(c1decimal - c2decimal);
		}

		public static LambdaParameterWrapper operator -(LambdaParameterWrapper c1) {
			var c1decimal = ConvertManager.ChangeType<decimal>(c1.Value);
			return new LambdaParameterWrapper(-c1decimal);
		}

		public static LambdaParameterWrapper operator *(LambdaParameterWrapper c1, LambdaParameterWrapper c2) {
			var c1decimal = ConvertManager.ChangeType<decimal>(c1.Value);
			var c2decimal = ConvertManager.ChangeType<decimal>(c2.Value);
			return new LambdaParameterWrapper(c1decimal * c2decimal);
		}

		public static LambdaParameterWrapper operator /(LambdaParameterWrapper c1, LambdaParameterWrapper c2) {
			var c1decimal = ConvertManager.ChangeType<decimal>(c1.Value);
			var c2decimal = ConvertManager.ChangeType<decimal>(c2.Value);
			return new LambdaParameterWrapper(c1decimal / c2decimal);
		}

		public static LambdaParameterWrapper operator %(LambdaParameterWrapper c1, LambdaParameterWrapper c2) {
			var c1decimal = ConvertManager.ChangeType<decimal>(c1.Value);
			var c2decimal = ConvertManager.ChangeType<decimal>(c2.Value);
			return new LambdaParameterWrapper(c1decimal % c2decimal);
		}

		public static bool operator ==(LambdaParameterWrapper c1, LambdaParameterWrapper c2) {
			var compareRes = Compare(c1.Value, c2.Value);
			return compareRes == 0;
		}
		public static bool operator ==(LambdaParameterWrapper c1, bool c2) {
			var c1bool = ConvertManager.ChangeType<bool>(c1.Value);
			return c1bool == c2;
		}
		public static bool operator ==(bool c1, LambdaParameterWrapper c2) {
			var c2bool = ConvertManager.ChangeType<bool>(c2.Value);
			return c1==c2bool;
		}

		public static bool operator !=(LambdaParameterWrapper c1, LambdaParameterWrapper c2) {
			var compareRes = Compare(c1.Value, c2.Value);
			return compareRes != 0;
		}
		public static bool operator !=(LambdaParameterWrapper c1, bool c2) {
			var c1bool = ConvertManager.ChangeType<bool>(c1.Value);
			return c1bool != c2;
		}
		public static bool operator !=(bool c1, LambdaParameterWrapper c2) {
			var c2bool = ConvertManager.ChangeType<bool>(c2.Value);
			return c1 != c2bool;
		}

		public static bool operator >(LambdaParameterWrapper c1, LambdaParameterWrapper c2) {
			var compareRes = Compare(c1.Value, c2.Value);
			return compareRes>0;
		}
		public static bool operator <(LambdaParameterWrapper c1, LambdaParameterWrapper c2) {
			var compareRes = Compare(c1.Value, c2.Value);
			return compareRes < 0;
		}

		public static bool operator >=(LambdaParameterWrapper c1, LambdaParameterWrapper c2) {
			var compareRes = Compare(c1.Value, c2.Value);
			return compareRes >= 0;
		}
		public static bool operator <=(LambdaParameterWrapper c1, LambdaParameterWrapper c2) {
			var compareRes = Compare(c1.Value, c2.Value);
			return compareRes <= 0;
		}

		internal static int Compare(object a, object b) {
			if (a == null && b == null)
				return 0;
			if (a == null && b != null)
				return -1;
			if (a != null && b == null)
				return 1;

			if ((a is IList) && (b is IList)) {
				IList aList = (IList)a;
				IList bList = (IList)b;
				if (aList.Count < bList.Count)
					return -1;
				if (aList.Count > bList.Count)
					return +1;
				for (int i = 0; i < aList.Count; i++) {
					int r = Compare(aList[i], bList[i]);
					if (r != 0)
						return r;
				}
				// lists are equal
				return 0;
			}
			if (a is IComparable) {

				// try to convert b to a type (because standard impl of IComparable for simple types are stupid enough)
				try {
					object bConverted = Convert.ChangeType(b, a.GetType());
					return ((IComparable)a).CompareTo(bConverted);
				} catch {
				}

				// try to compare without any conversions
				try {
					return ((IComparable)a).CompareTo(b);
				} catch { }


			}
			if (b is IComparable) {
				// try to compare without any conversions
				try {
					return -((IComparable)b).CompareTo(a);
				} catch { }

				// try to convert a to b type
				try {
					object aConverted = Convert.ChangeType(a, b.GetType());
					return -((IComparable)b).CompareTo(aConverted);
				} catch {
				}
			}

			throw new Exception("Cannot compare");
		}

	}

}
