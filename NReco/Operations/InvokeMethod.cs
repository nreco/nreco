using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using System.Reflection;

using NReco.Converters;

namespace NReco.Operations {
	
	/// <summary>
	/// Invoke operation supports internal composition mechanism used by model transformer.
	/// </summary>
	public class InvokeMethod : IOperation, IProvider {
		string _MethodName;
		object _TargetObject;
		object[] _Arguments;
		ITypeConverter _TypeConverter;

		public ITypeConverter TypeConverter {
			get { return _TypeConverter; }
			set { _TypeConverter = value; }
		}

		public object[] Arguments {
			get { return _Arguments; }
			set { _Arguments = value; }
		}

		public object TargetObject {
			get { return _TargetObject; }
			set { _TargetObject = value; }
		}

		public string MethodName {
			get { return _MethodName; }
			set { _MethodName = value; }
		}

		public InvokeMethod() {

		}

		public InvokeMethod(object o, string targetMethod, object[] targetArgs) {
			TargetObject = o;
			MethodName = targetMethod;
			Arguments = targetArgs;
		}

		public void Execute(object context) {
			Provide(context);
		}

		public object Provide(object context) {
			Type[] argTypes = new Type[Arguments.Length];
			for (int i = 0; i < argTypes.Length; i++)
				argTypes[i] = Arguments[i] != null ? Arguments[i].GetType() : typeof(object);

			// strict matching
			Type targetType = TargetObject.GetType();
			MethodInfo targetMethodInfo = targetType.GetMethod(MethodName, argTypes);
			if (targetMethodInfo==null) {
				MethodInfo[] methods = targetType.GetMethods();
				for (int i=0; i<methods.Length; i++)
					if (methods[i].Name==MethodName &&
						methods[i].GetParameters().Length==Arguments.Length &&
						CheckParamsCompatibility(methods[i].GetParameters(),argTypes,Arguments)) {
						targetMethodInfo = methods[i];
					}
			}
			if (targetMethodInfo == null) {
				string[] argTypeNames = new string[argTypes.Length];
				for (int i=0; i<argTypeNames.Length; i++)
					argTypeNames[i] = argTypes[i].Name;
				throw new MissingMethodException(
					String.Format("Method not found: {0}({1})", TargetObject.GetType(), String.Join(",",argTypeNames) ) );
			}
			object[] argValues = PrepareActualValues(targetMethodInfo.GetParameters(),Arguments);
			return targetMethodInfo.Invoke(TargetObject, argValues);
		}

		protected bool CheckParamsCompatibility(ParameterInfo[] paramsInfo, Type[] types, object[] values) {
			for (int i=0; i<paramsInfo.Length; i++) {
				Type paramType = paramsInfo[i].ParameterType;
				if (paramType.IsInstanceOfType(values[i]))
					continue;
				// null and reference types
				if (values[i]==null && paramType.IsValueType)
					continue;
				// possible autocast between generic/non-generic common types
				if (TypeConverter.CanConvert(types[i],paramType))
					continue;

				// incompatible parameter
				return false;
			}
			return true;
		}

		protected object[] PrepareActualValues(ParameterInfo[] paramsInfo, object[] values) {
			object[] res = new object[paramsInfo.Length];
			for (int i=0; i<paramsInfo.Length; i++) {
				if (values[i]==null || paramsInfo[i].ParameterType.IsInstanceOfType(values[i])) {
					res[i] = values[i];
					continue;
				}
				if (TypeConverter.CanConvert(values[i].GetType(), paramsInfo[i].ParameterType)) {
					res[i] = TypeConverter.Convert( values[i], paramsInfo[i].ParameterType );
					continue;
				}
				// cannot cast?
			}
			return res;
		}


	}

}
