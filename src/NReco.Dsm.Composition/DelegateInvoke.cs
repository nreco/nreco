#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2014 Vitaliy Fedorchenko
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
using System.Reflection;
using System.Text;

using NReco.Logging;
using NReco.Converting;

namespace NReco.Dsm.Composition {

	/// <summary>
	/// Invokes the specified delegate
	/// </summary>
	public class DelegateInvoke : IStatement {
		
		public Delegate TargetDelegate { get; private set; }

		public ICollection<Func<IDictionary<string,object>, object>> Arguments { get; private set; }

		public string ResultKey { get; set; }

		public DelegateInvoke(Delegate d, ICollection<Func<IDictionary<string, object>, object>> args, string resultKey) {
			TargetDelegate = d;
			Arguments = args;
			ResultKey = resultKey;
		}

		public virtual void Execute(IDictionary<string, object> context) {
			var delegParams = TargetDelegate.Method.GetParameters();
			if (delegParams.Length!=Arguments.Count)
				throw new TargetParameterCountException(
					String.Format("Delegate {0} requires {1} parameter(s)", TargetDelegate.GetType(), delegParams.Length ) );

			var argValues = new object[Arguments.Count];
			var i = 0;
			foreach (var argFunc in Arguments) {
				var argValue = argFunc(context);
				argValues[i] = ConvertManager.ChangeType(argValue, delegParams[i].ParameterType);
				i++;
			}
			var invokeResult = TargetDelegate.DynamicInvoke( argValues );

			if (ResultKey != null)
				context[ResultKey] = invokeResult;
		}

	}

}
