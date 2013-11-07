#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2013 Vitaliy Fedorchenko
 * Distributed under the LGPL licence
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#endregion

using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using NReco.Collections;
using System.ComponentModel;

namespace NReco.Converting {

	/// <summary>
	/// Delegate and SAM-interfaces converter.
	/// </summary>
    public class DelegateConverter : ITypeConverter
    {

		public DelegateConverter() {
		}

		public virtual bool CanConvert(Type fromType, Type toType) {
			return 
				(TypeHelper.IsDelegate(fromType) || TypeHelper.IsFunctionalInterface(fromType))
				&&
				(TypeHelper.IsDelegate(toType) || TypeHelper.IsFunctionalInterface(toType));
		}

		protected MethodInfo FindMethod(object o, int paramsCount) {
			var t = o.GetType();
			if (o is Delegate) {
				var d = (Delegate)o;
				if (d.Method.GetParameters().Length == paramsCount)
					return d.Method;
				else
					throw new ArgumentException("Incompatible number of delegate parameters");
			}
			var interfaces = t.GetInterfaces();
			foreach (var i in interfaces) {
				if (TypeHelper.IsFunctionalInterface(i)) {
					var method = i.GetMethods()[0];
					if (method.GetParameters().Length == paramsCount)
						return method;
				}
			}
			throw new MissingMethodException();
		}

		public virtual object Convert(object o, Type toType) {
			if (o == null)
				return null;

			if (TypeHelper.IsDelegate(toType)) {
				return ConvertToDelegate(o, toType);
			}
			if (TypeHelper.IsFunctionalInterface(toType)) {
				return ConvertToFuncInterface(o, toType);
			}

			throw new InvalidCastException();
		}

		protected object ConvertToFuncInterface(object o, Type toType) {
			throw new NotImplementedException();
		}

		protected object ConvertToDelegate(object o, Type toType) {
			var toMethodInfo = toType.GetMethod("Invoke");
			var toMethodParamCount = toMethodInfo.GetParameters().Length;
			var fromMethod = FindMethod(o, toMethodParamCount);
			// simplest case - when parameters are contravariant and result is covariant
			var toDelegate = Delegate.CreateDelegate(toType, o, fromMethod, false);
			if (toDelegate != null)
				return toDelegate;

			// use adapter with run-time types conversion
			var adapter = new DelegateAdapter(o, fromMethod);
			foreach (var adapterMethod in adapter.GetType().GetMethods()) {
				if (adapterMethod.Name == "Invoke" && adapterMethod.GetParameters().Length == toMethodParamCount) {
					var resType = toMethodInfo.ReturnType != typeof(void) ? toMethodInfo.ReturnType : typeof(object);
					var typedInvokeMethod = adapterMethod.MakeGenericMethod(resType);
					return Delegate.CreateDelegate(toType, adapter, typedInvokeMethod, true);
				}
			}

			throw new InvalidCastException();
		}

		class DelegateAdapter {
			object Target;
			MethodInfo Method;
			
			public DelegateAdapter(object o, MethodInfo m) {
				Target = o;
				Method = m;
			}

			protected object Invoke(params object[] args) {
				var mParams = Method.GetParameters();
				for (int i = 0; i < args.Length; i++) {
					if (args[i]!=null) {
						if (mParams.Length > i && !mParams[i].ParameterType.IsAssignableFrom(args[i].GetType())) {
							args[i] = ConvertManager.ChangeType(args[i], mParams[i].ParameterType);
						}
					}
				}
				return Method.Invoke(Target, args);
			}

			public T Invoke<T>() {
				return (T)ConvertManager.ChangeType(Invoke(), typeof(T));
			}
			public T Invoke<T>(object arg1) {
				return (T)ConvertManager.ChangeType(Invoke(arg1), typeof(T));
			}
			public T Invoke<T>(object arg1, object arg2) {
				return (T)ConvertManager.ChangeType(Invoke(arg1,arg2), typeof(T));
			}
			public T Invoke<T>(object arg1, object arg2, object arg3) {
				return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3), typeof(T));
			}
			public T Invoke<T>(object arg1, object arg2, object arg3, object arg4) {
				return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4), typeof(T));
			}
			public T Invoke<T>(object arg1, object arg2, object arg3, object arg4, object arg5) {
				return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5), typeof(T));
			}
			public T Invoke<T>(object arg1, object arg2, object arg3, object arg4, object arg5, object arg6) {
				return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6), typeof(T));
			}
			public T Invoke<T>(object arg1, object arg2, object arg3, object arg4, object arg5, object arg6, object arg7) {
				return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7), typeof(T));
			}
			public T Invoke<T>(object arg1, object arg2, object arg3, object arg4, object arg5, object arg6, object arg7, object arg8) {
				return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8), typeof(T));
			}
			public T Invoke<T>(object arg1, object arg2, object arg3, object arg4, object arg5, object arg6, object arg7, object arg8,
								object arg9) {
				return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9), typeof(T));
			}
			public T Invoke<T>(object arg1, object arg2, object arg3, object arg4, object arg5, object arg6, object arg7, object arg8,
								object arg9, object arg10) {
				return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10), typeof(T));
			}
			public T Invoke<T>(object arg1, object arg2, object arg3, object arg4, object arg5, object arg6, object arg7, object arg8,
								object arg9, object arg10, object arg11) {
				return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11), typeof(T));
			}
			public T Invoke<T>(object arg1, object arg2, object arg3, object arg4, object arg5, object arg6, object arg7, object arg8,
								object arg9, object arg10, object arg11, object arg12) {
				return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12), typeof(T));
			}
			public T Invoke<T>(object arg1, object arg2, object arg3, object arg4, object arg5, object arg6, object arg7, object arg8,
								object arg9, object arg10, object arg11, object arg12, object arg13) {
				return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13), typeof(T));
			}
			public T Invoke<T>(object arg1, object arg2, object arg3, object arg4, object arg5, object arg6, object arg7, object arg8,
								object arg9, object arg10, object arg11, object arg12, object arg13, object arg14) {
				return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14), typeof(T));
			}
		}

	}

}
