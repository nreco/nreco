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

namespace NReco.Web {
	
	/// <summary>
	/// Action handler based on service instance.
	/// </summary>
	public class ServiceHandler : IProvider<ActionContext,IOperation<ActionContext>> {
		string _OperationName;
		IProvider<string, IOperation<ActionContext>> _InstanceProvider;

		public IProvider<ActionContext, bool> Match { get; set; }

		public IProvider<string, IOperation<ActionContext>> InstanceProvider {
			get { return _InstanceProvider; }
			set { _InstanceProvider = value; }
		}

		public string OperationName {
			get { return _OperationName; }
			set { _OperationName = value; }
		}

		public IOperation<ActionContext> Provide(ActionContext context) {
			if (Match==null || Match.Provide(context)) {
				return InstanceProvider.Provide(OperationName);
			}
			return null;
		}

	}
}
