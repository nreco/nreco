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
using System.Text;
using NReco.Logging;

namespace NReco.Composition {
	
	/// <summary>
	/// Lazy operation proxy
	/// </summary>
	public class LazyOperation<C> : IOperation<C> {
		IProvider<string, IOperation<C>> _InstanceProvider;
		string _OperationName;
		static ILog log = LogManager.GetLogger(typeof(LazyOperation));

		public string OperationName {
			get { return _OperationName; }
			set { _OperationName = value; }
		}

		public IProvider<string, IOperation<C>> InstanceProvider {
			get { return _InstanceProvider; }
			set { _InstanceProvider = value; }
		}

		public void Execute(C context) {
			var operation = InstanceProvider.Provide(OperationName);
			if (operation==null) {
				log.Write(
					LogEvent.Error,
					new{Action="getting real instance",Msg="Not found",OperationName=OperationName}
				);
				throw new NullReferenceException("Operation instance not found: "+OperationName);
			}
			operation.Execute(context);
		}

	}

	public class LazyOperation : LazyOperation<object> {
		public LazyOperation() { }
	}


}
