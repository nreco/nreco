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

namespace NReco {

	/// <summary>
	/// Expression context.
	/// </summary>
	/// <typeparam name="ExprT">expression type</typeparam>
	[Serializable]
	public class ExpressionContext<ExprT> : Context {
		ExprT _Expression;
		IDictionary<string,object> _Variables;

		public ExprT Expression {
			get { return _Expression; }
		}
		public IDictionary<string,object> Variables {
			get { return _Variables; }
		}

		public ExpressionContext(ExprT expr, IDictionary<string, object> vars) {
			_Expression = expr;
			_Variables = vars;
		}

		public override string ToString() {
			return base.ToString();
		}

	}

}
