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
using System.Linq.Expressions;
using System.Text;
using NReco.Collections;
using System.ComponentModel;

using System.Runtime.Remoting;
using System.Runtime.Remoting.Messaging;
using NReco.Logging;

namespace NReco.Converting {

	/// <summary>
	/// Delegate and SAM-interfaces converter.
	/// </summary>
    public class DelegateConverter : ITypeConverter
    {

		public DelegateConverter() {
		}

		protected bool ImplementsCompatibleFunctionalInterface(Type t, int paramsCount) {
			if (TypeHelper.IsFunctionalInterface(t))
				return t.GetMethods()[0].GetParameters().Length==paramsCount;
			var interfaces = t.GetInterfaces();
			int compatInterfacesCount = 0;
			foreach (var i in interfaces)
				if (TypeHelper.IsFunctionalInterface(i) && i.GetMethods()[0].GetParameters().Length == paramsCount)
					compatInterfacesCount++;
			// type should implement only one suitable func interface
			if (compatInterfacesCount == 1)
				return true;
			return false;
		}

		public virtual bool CanConvert(Type fromType, Type toType) {
			var isToDeleg = TypeHelper.IsDelegate(toType);
			var isToFuncInterface = TypeHelper.IsFunctionalInterface(toType);

			if (!isToDeleg && !isToFuncInterface)
				return false;

			int paramsCount;
			if (isToDeleg) {
				paramsCount = toType.GetMethod("Invoke").GetParameters().Length;
			} else {
				paramsCount = toType.GetMethods()[0].GetParameters().Length;
			}

			return
				(TypeHelper.IsDelegate(fromType) && fromType.GetMethod("Invoke").GetParameters().Length == paramsCount)
				|| 
				ImplementsCompatibleFunctionalInterface(fromType, paramsCount);
		}

		protected void FindMethod(object o, int paramsCount, out object targetObj, out MethodInfo m) {
			var t = o.GetType();
			if (o is Delegate) {
				var d = (Delegate)o;
				if (d.Method.GetParameters().Length == paramsCount) {
					m = d.Method;
					targetObj = d.Target;
					return;
				}  else
					throw new ArgumentException("Incompatible number of delegate parameters");
			}
			var interfaces = t.GetInterfaces();
			foreach (var i in interfaces) {
				if (TypeHelper.IsFunctionalInterface(i)) {
					var method = i.GetMethods()[0];
					if (method.GetParameters().Length == paramsCount) {
						targetObj = o;
						m = method;
						return;

					}
				}
			}
			throw new Exception(String.Format("Cannot find functional interface with method for {0} parameters", paramsCount));
		}

		public virtual object Convert(object o, Type toType) {
			if (o == null)
				return null;

			try {
				if (TypeHelper.IsDelegate(toType)) {
					return ConvertToDelegate(o, toType);
				}
				if (TypeHelper.IsFunctionalInterface(toType)) {
					return ConvertToFuncInterface(o, toType);
				}
			} catch (Exception ex) {
				throw new InvalidCastException(
					String.Format("Cannot convert {0} to {1}: {2}", o.GetType().ToString(), toType.ToString(), ex.Message), ex);
			}

			throw new InvalidCastException();
		}

		/// <summary>
		/// Returns appropriate Func<> or Action<> delegate type by MethodInfo
		/// </summary>
		protected Type GetDelegateType(MethodInfo m) {
			var mParams = m.GetParameters();
			if (m.ReturnType != typeof(void)) {
				var delegTypes = new Type[mParams.Length + 1];
				for (int i = 0; i < mParams.Length; i++)
					delegTypes[i] = mParams[i].ParameterType;
				delegTypes[mParams.Length] = m.ReturnType;
				return Expression.GetFuncType(delegTypes);
			} else {
				var delegTypes = new Type[mParams.Length];
				for (int i = 0; i < mParams.Length; i++)
					delegTypes[i] = mParams[i].ParameterType;
				return Expression.GetActionType(delegTypes);
			}
		}

		protected object ConvertToFuncInterface(object o, Type toType) {
			var toMethod = toType.GetMethods()[0]; // SAM-interface contains exactly 1 method
			var toMethodParamCount = toMethod.GetParameters().Length;
			MethodInfo fromMethod;
			object fromObject;
			FindMethod(o, toMethodParamCount, out fromObject, out fromMethod);

			// simplest case - maybe explicit conversion from delegate already exists
			var fromDelegateGenericType = GetDelegateType(fromMethod);
			var defConv = new DefaultConverter();
			if (defConv.CanConvert(fromDelegateGenericType, toType)) {
				var funcDeleg = Delegate.CreateDelegate(fromDelegateGenericType, fromObject, fromMethod, true);
				return defConv.Convert(funcDeleg, toType);
			}

			// universal impementation - real proxy
			var interfaceProxy = new InterfaceAdapter(toType, toMethod, fromObject, fromMethod);
			return interfaceProxy.GetTransparentProxy();
		}

		protected object ConvertToDelegate(object o, Type toType) {
			var toMethodInfo = toType.GetMethod("Invoke");
			var toMethodParams = toMethodInfo.GetParameters();
			var toMethodParamCount = toMethodParams.Length;
			MethodInfo fromMethod;
			object fromObject;
			FindMethod(o, toMethodParamCount, out fromObject, out fromMethod);

			// simplest case - when parameters are contravariant and result is covariant
			var toDelegate = Delegate.CreateDelegate(toType, fromObject, fromMethod, false);
			if (toDelegate != null)
				return toDelegate;

			// use adapter with run-time types conversion
			var adapter = new DynamicDelegateAdapter(fromObject, fromMethod);
			return adapter.GetDelegate(toType);
		}

		class DynamicDelegateAdapter : DelegateAdapter {
			object Target;
			MethodInfo Method;

			public DynamicDelegateAdapter(object o, MethodInfo m) {
				Target = o;
				Method = m;
			}

			protected override object Invoke(params object[] args) {
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

		}


		class InterfaceAdapter : System.Runtime.Remoting.Proxies.RealProxy, IRemotingTypeInfo {
			object Target;
			MethodInfo Method;
			Type InterfaceType;
			MethodInfo InterfaceMethod;

			public InterfaceAdapter(Type interfaceType, MethodInfo iMethod, object o, MethodInfo m) : base(interfaceType) {
				InterfaceType = interfaceType;
				InterfaceMethod = iMethod;
				Target = o;
				Method = m;
			}

			public override IMessage Invoke(IMessage m) {
				if (m is IMethodCallMessage) {
					var methodCall = (IMethodCallMessage)m;

					var args = (object[])methodCall.Args.Clone();
					// check args contravariance
					var mParams = Method.GetParameters();
					for (int i = 0; i < args.Length; i++) {
						if (args[i] != null) {
							if (mParams.Length > i && !mParams[i].ParameterType.IsAssignableFrom(args[i].GetType())) {
								try {
									args[i] = ConvertManager.ChangeType(args[i], mParams[i].ParameterType);
								} catch (Exception ex) {
									throw new InvalidCastException(
										String.Format("Cannot convert parameter #{0} for {1}.{2} -> {3}.{4}: {5}", 
											i, InterfaceType.ToString(), InterfaceMethod.Name,
											Method.DeclaringType.ToString(), Method.Name,
											ex.Message), ex);
								}
							}
						}
					}
					var response = Method.Invoke(Target, args);
					if (response != null && InterfaceMethod.ReturnType != typeof(void) && !InterfaceMethod.ReturnType.IsAssignableFrom(response.GetType())) {
						try {
							response = ConvertManager.ChangeType(response, InterfaceMethod.ReturnType);
						} catch (Exception ex) {
							throw new InvalidCastException(
								String.Format("Cannot convert result for {0}.{1} -> {2}.{3}: {2}",
									InterfaceType.ToString(), InterfaceMethod.Name,
									Method.DeclaringType.ToString(), Method.Name,
									ex.Message), ex);
						}
					}
					return new ReturnMessage(response, null, 0, null, methodCall);
				}
				throw new NotImplementedException();
			}

			string IRemotingTypeInfo.TypeName { get { return InterfaceType.Name; } set { throw new NotImplementedException(); } }

			bool IRemotingTypeInfo.CanCastTo(Type fromType, Object o) {
				return fromType == InterfaceType;
			}
		}


	}

}
