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
	
	public class ThreadImpersonate : IStatement {

		Func<IDictionary<string, object>, IPrincipal> Principal;
		IStatement Target;

		public ThreadImpersonate(Func<IDictionary<string,object>,IPrincipal> principal, IStatement target) {
			Principal = principal;
			Target = target;
		}

		public void Execute(IDictionary<string, object> context) {
			var origPrincipal = Thread.CurrentPrincipal;
			try {
				Thread.CurrentPrincipal = Principal(context);
				Target.Execute(context);
			} finally {
				Thread.CurrentPrincipal = origPrincipal;
			}
		}
	}
}
