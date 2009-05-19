#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008,2009 Vitaliy Fedorchenko
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
using System.Collections.Generic;
using System.Collections;
using System.Text;
using System.Reflection;

using NReco.Converting;
using NReco.Logging;

namespace NReco.Composition {
	
	/// <summary>
	/// Invoke operation supports internal composition mechanism used by model transformer.
	/// </summary>
	public class InvokeMethod : IOperation<object>, IProvider<object,object> {
		string _MethodName;
		object _TargetObject;
		object[] _Arguments;
		static ILog log = LogManager.GetLogger(typeof(InvokeMethod));

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
				string argTypeNamesStr = String.Join(",",argTypeNames);
				log.Write(
					LogEvent.Error,
					new {Action="invoking", Msg="Method not found",Method=MethodName,ArgTypes=argTypeNamesStr}
				);
				throw new MissingMethodException( TargetObject.GetType().FullName, MethodName );
			}
			object[] argValues = PrepareActualValues(targetMethodInfo.GetParameters(),Arguments);
			object res = targetMethodInfo.Invoke(TargetObject, argValues);
			if (log.IsEnabledFor(LogEvent.Debug))
				log.Write(
					LogEvent.Debug,
					new{Action="method invoked",Method=MethodName,Result=res}
				);
			return res;
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
				if (ConvertManager.CanChangeType(types[i],paramType))
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
				var conv = ConvertManager.FindConverter(values[i].GetType(), paramsInfo[i].ParameterType);
				if (conv!=null) {
					res[i] = conv.Convert( values[i], paramsInfo[i].ParameterType );
					continue;
				}
				// cannot cast?
				log.Write(LogEvent.Error,
					new { Action = "Converting args", Msg = "cannot cast", FromType = values[i].GetType(), ToType = paramsInfo[i].ParameterType });
				throw new InvalidCastException();
			}
			return res;
		}


	}

}
