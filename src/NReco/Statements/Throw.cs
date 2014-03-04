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
using System.Linq;
using System.Text;
using System.Threading;
using System.Security;
using System.Security.Principal;

namespace NReco.Statements {
	
	public class Throw : IStatement {

		Func<IDictionary<string, object>, Exception> ExceptionFactory;

		public Throw(string message) {
			ExceptionFactory = (c) => { return new Exception(message); };
		}

		public Throw(Func<IDictionary<string, object>, Exception> exceptionFactory) {
			ExceptionFactory = exceptionFactory;
		}

		public void Execute(IDictionary<string, object> context) {
			throw ExceptionFactory(context);
		}
	}
}
