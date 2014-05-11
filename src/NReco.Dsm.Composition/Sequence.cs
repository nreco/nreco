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
using System.Text;
using NReco.Converting;

namespace NReco.Dsm.Composition {

	/// <summary>
	/// Chain of actions
	/// </summary>
	public class Sequence : IStatement {
		
		/// <summary>
		/// Get or set chain operations list.
		/// </summary>
		public ICollection<IStatement> Statements { get; private set; }

		public Sequence(ICollection<IStatement> statements) {
			Statements = statements;
		}

		public void Execute(IDictionary<string, object> context) {
			foreach (var st in Statements)
				st.Execute(context);
		}


	}


}
