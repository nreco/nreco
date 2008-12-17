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
	/// Generic implementation of action handler 
	/// </summary>
	public class ActionHandler : IActionHandler {
		string _OperationName;
		IProvider<string, IOperation<ActionContext>> _InstanceProvider;
		IProvider<ActionContext, bool> _Matcher;

		public IProvider<ActionContext, bool> Matcher {
			get { return _Matcher; }
			set { _Matcher = value; }
		}

		public IProvider<string, IOperation<ActionContext>> InstanceProvider {
			get { return _InstanceProvider; }
			set { _InstanceProvider = value; }
		}

		public string OperationName {
			get { return _OperationName; }
			set { _OperationName = value; }
		}

		public bool IsMatch(ActionContext action) {
			return Matcher.Provide(action);
		}

		public IOperation<ActionContext> Operation {
			get {
				return InstanceProvider.Provide(OperationName);
			}
		}

	}
}
