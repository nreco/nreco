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
using System.Threading;
using System.Security.Principal;

using NReco;

namespace NReco.Composition {
	
	/// <summary>
	/// Impersonator - executes underlying operation under another principal
	/// </summary>
	/// <typeparam name="C">Operation context type</typeparam>
	public class ThreadImpersonator<C> : IOperation<C> {

		public IOperation<C> UnderlyingOperation { get; set; }

		public IProvider<C,IPrincipal> PrincipalProvider { get; set; }

		public ThreadImpersonator() { }

		public void Execute(C context) {
			var currentPrincipal = Thread.CurrentPrincipal;
			try {
				Thread.CurrentPrincipal = PrincipalProvider.Provide(context);
				UnderlyingOperation.Execute(context);
			} finally {
				Thread.CurrentPrincipal = currentPrincipal;
			}
		}

	}

	public class ThreadImpersonator : ThreadImpersonator<object> {
		public ThreadImpersonator() { }
	}

}
