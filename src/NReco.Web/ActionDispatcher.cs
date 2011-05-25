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

using System.Web;
using System.Web.UI;

namespace NReco.Web {
	
	/// <summary>
	/// Action dispatcher that implements UI action execution logic
	/// </summary>
	public class ActionDispatcher : IOperation<ActionContext> {

		/// <summary>
		/// Get or set action handlers list
		/// </summary>
		public IProvider<ActionContext, IOperation<ActionContext>>[] Handlers { get; set; }

		/// <summary>
		/// Get or set found operations list filters
		/// </summary>
		public IOperation<ActionFilterContext>[] Filters { get; set; }
		
		private bool isRecursiveExecute = false;
		
		public void Execute(ActionContext context) {
			var isFirstExecute = !isRecursiveExecute;
			isRecursiveExecute = true;
			try {
				// collect operations
				IList<IOperation<ActionContext>> operations = new List<IOperation<ActionContext>>();
				if (Handlers!=null) 
					for (int i=0; i<Handlers.Length; i++) {
						IOperation<ActionContext> op = Handlers[i].Provide(context);
						if (op != null)
							operations.Add(op);
					}
				// apply filters
				if (Filters != null) {
					ActionFilterContext filterContext = new ActionFilterContext(context) { Operations = operations };
					for (int i = 0; i < Filters.Length; i++) {
						Filters[i].Execute(filterContext);
					}
					operations = filterContext.Operations;
				}

				// execute operations
				foreach (IOperation<ActionContext> op in operations)
					op.Execute(context);

				// if some handler performs redirect, lets finish current request
				if (HttpContext.Current.Response.IsRequestBeingRedirected && isFirstExecute && context.ResponseEndRequested)
					HttpContext.Current.Response.End();
			} finally {
				if (isFirstExecute)
					isRecursiveExecute = false;
			}			
		}
	}

	public class ActionFilterContext : Context {
		public ActionContext ActionContext { get; private set; }
		public IList<IOperation<ActionContext>> Operations { get; set; }

		public ActionFilterContext(ActionContext aContext) {
			ActionContext = aContext;
		}
	}

}
