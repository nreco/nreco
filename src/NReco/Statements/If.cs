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

using NReco.Logging;

namespace NReco.Statements {

	/// <summary>
	/// If action
	/// </summary>
	public class If : IStatement {

		public Func<IDictionary<string, object>, bool> Condition { get; private set; }

		public IStatement ThenStatement { get; private set; }

		public IStatement ElseStatement { get; private set; }

		public If(Func<IDictionary<string, object>, bool> condition, IStatement thenStatement, IStatement elseStatement) {
			Condition = condition;
			ThenStatement = thenStatement;
			ElseStatement = elseStatement;
		}

		public virtual void Execute(IDictionary<string, object> context) {
			if (Condition(context)) {
				if (ThenStatement != null)
					ThenStatement.Execute(context);
			} else {
				if (ElseStatement != null)
					ElseStatement.Execute(context);
			}
		}

	}

}
