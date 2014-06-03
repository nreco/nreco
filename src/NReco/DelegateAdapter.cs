using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;
using NReco.Converting;

namespace NReco {
	
	/// <summary>
	/// Provides generic functionality for constructing dynamic delegates at runtime
	/// </summary>
	public abstract class DelegateAdapter {

		public DelegateAdapter() {
		}

		protected abstract object Invoke(params object[] args);

		static MethodInfo[] invokeAdapterMethods = typeof(DelegateAdapter).GetMethods();

		public MethodInfo GetInvokeGenericMethod(int argsCount, bool hasReturn) {
			var methodName = hasReturn ? "InvokeFunc" : "InvokeAction";
			foreach (var adapterMethod in invokeAdapterMethods) {
				if (adapterMethod.Name == methodName && adapterMethod.GetParameters().Length == argsCount) {
					return adapterMethod;
				}
			}
			throw new TargetParameterCountException( String.Format("Invoke with {0} parameters doesn't exist", argsCount));
		}

		public T GetDelegate<T>() where T: class {
			return GetDelegate(typeof(T)) as T;
		}

		public Delegate GetDelegate(Type delegType) {
			if (!delegType.IsSubclassOf(typeof(Delegate)))
				throw new ArgumentException("Expected type of delegate", "delegType");

			var toMethodInfo = delegType.GetMethod("Invoke");
			var toMethodParams = toMethodInfo.GetParameters();
			var toMethodParamCount = toMethodParams.Length;
			var hasReturn = toMethodInfo.ReturnType != typeof(void);

			var invokeGenericMethod = GetInvokeGenericMethod(toMethodParamCount, hasReturn);

			var genericTypes = new Type[toMethodParamCount + (hasReturn ? 1 : 0)];
			for (int i = 0; i < toMethodParams.Length; i++)
				genericTypes[i] = toMethodParams[i].ParameterType;
			if (hasReturn)
				genericTypes[toMethodParamCount] = toMethodInfo.ReturnType; // last type for result

			var typedInvokeMethod = genericTypes.Length>0 ? invokeGenericMethod.MakeGenericMethod(genericTypes) : invokeGenericMethod;
			return Delegate.CreateDelegate(delegType, this, typedInvokeMethod, true);
		}

		public void InvokeAction() {
			Invoke();
		}
		public void InvokeAction<P1>(P1 arg1) {
			Invoke(arg1);
		}
		public void InvokeAction<P1,P2>(P1 arg1, P2 arg2) {
			Invoke(arg1,arg2);
		}
		public void InvokeAction<P1, P2, P3>(P1 arg1, P2 arg2, P3 arg3) {
			Invoke(arg1, arg2, arg3);
		}
		public void InvokeAction<P1, P2, P3, P4>(P1 arg1, P2 arg2, P3 arg3, P4 arg4) {
			Invoke(arg1, arg2, arg3, arg4);
		}
		public void InvokeAction<P1, P2, P3, P4, P5>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5) {
			Invoke(arg1, arg2, arg3, arg4, arg5);
		}
		public void InvokeAction<P1, P2, P3, P4, P5, P6>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6) {
			Invoke(arg1, arg2, arg3, arg4, arg5, arg6);
		}
		public void InvokeAction<P1, P2, P3, P4, P5, P6, P7>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7) {
			Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7);
		}
		public void InvokeAction<P1, P2, P3, P4, P5, P6, P7, P8>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7, P8 arg8) {
			Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
		}
		public void InvokeAction<P1, P2, P3, P4, P5, P6, P7, P8, P9>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7, P8 arg8, P9 arg9) {
			Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
		}
		public void InvokeAction<P1, P2, P3, P4, P5, P6, P7, P8, P9, P10>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7, P8 arg8, P9 arg9, P10 arg10) {
			Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
		}
		public void InvokeAction<P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7, P8 arg8, P9 arg9, P10 arg10, P11 arg11) {
			Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11);
		}
		public void InvokeAction<P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7, P8 arg8, P9 arg9, P10 arg10, P11 arg11, P12 arg12) {
			Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
		}
		public void InvokeAction<P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7, P8 arg8, P9 arg9, P10 arg10, P11 arg11, P12 arg12, P13 arg13) {
			Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13);
		}
		public void InvokeAction<P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7, P8 arg8, P9 arg9, P10 arg10, P11 arg11, P12 arg12, P13 arg13, P14 arg14) {
			Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
		}

		public T InvokeFunc<T>() {
			return (T)ConvertManager.ChangeType(Invoke(), typeof(T));
		}
		public T InvokeFunc<P1, T>(P1 arg1) {
			return (T)ConvertManager.ChangeType(Invoke(arg1), typeof(T));
		}
		public T InvokeFunc<P1, P2, T>(P1 arg1, P2 arg2) {
			return (T)ConvertManager.ChangeType(Invoke(arg1, arg2), typeof(T));
		}
		public T InvokeFunc<P1, P2, P3, T>(P1 arg1, P2 arg2, P3 arg3) {
			return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3), typeof(T));
		}
		public T InvokeFunc<P1, P2, P3, P4, T>(P1 arg1, P2 arg2, P3 arg3, P4 arg4) {
			return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4), typeof(T));
		}
		public T InvokeFunc<P1, P2, P3, P4, P5, T>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5) {
			return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5), typeof(T));
		}
		public T InvokeFunc<P1, P2, P3, P4, P5, P6, T>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6) {
			return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6), typeof(T));
		}
		public T InvokeFunc<P1, P2, P3, P4, P5, P6, P7, T>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7) {
			return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7), typeof(T));
		}
		public T InvokeFunc<P1, P2, P3, P4, P5, P6, P7, P8, T>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7, P8 arg8) {
			return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8), typeof(T));
		}
		public T InvokeFunc<P1, P2, P3, P4, P5, P6, P7, P8, P9, T>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7, P8 arg8, P9 arg9) {
			return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9), typeof(T));
		}
		public T InvokeFunc<P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, T>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7, P8 arg8, P9 arg9, P10 arg10) {
			return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10), typeof(T));
		}
		public T InvokeFunc<P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, T>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7, P8 arg8, P9 arg9, P10 arg10, P11 arg11) {
			return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11), typeof(T));
		}
		public T InvokeFunc<P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, T>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7, P8 arg8, P9 arg9, P10 arg10, P11 arg11, P12 arg12) {
			return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12), typeof(T));
		}
		public T InvokeFunc<P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, T>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7, P8 arg8, P9 arg9, P10 arg10, P11 arg11, P12 arg12, P13 arg13) {
			return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13), typeof(T));
		}
		public T InvokeFunc<P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, T>(P1 arg1, P2 arg2, P3 arg3, P4 arg4, P5 arg5, P6 arg6, P7 arg7, P8 arg8, P9 arg9, P10 arg10, P11 arg11, P12 arg12, P13 arg13, P14 arg14) {
			return (T)ConvertManager.ChangeType(Invoke(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14), typeof(T));
		}

	}
}
