#region License
/*
 * NReco library (http://code.google.com/p/nreco/)
 * Copyright 2008 Vitaliy Fedorchenko
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
using System.Text;
using NReco.Logging;

namespace NReco.Operations {
	
	/// <summary>
	/// Lazy operation proxy
	/// </summary>
	public class LazyOperation: IOperation {
		IProvider<string, IOperation> _InstanceProvider;
		string _OperationName;
		ILog log = LogManager.GetLogger(typeof(LazyOperation));

		public string OperationName {
			get { return _OperationName; }
			set { _OperationName = value; }
		}

		public IProvider<string, IOperation> InstanceProvider {
			get { return _InstanceProvider; }
			set { _InstanceProvider = value; }
		}

		public void Execute(object context) {
			IOperation operation = InstanceProvider.Provide(OperationName);
			if (operation==null) {
				log.Write(
					LogEvent.Error,
					new string[] {"action", "msg", "operationName"},
					new object[] {"getRealInstance", "Not found", OperationName}
				);
				throw new NullReferenceException("Operation instance not found: "+OperationName);
			}
			operation.Execute(context);
		}

	}


}
