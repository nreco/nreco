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

namespace NReco.Functions {

	/// <summary>
	/// If action
	/// </summary>
	public class IfAction {

		public Func<IDictionary<string, object>, bool> Condition { get; private set; }

		public Action<IDictionary<string,object>> Target { get; private set; }


		public IfAction(Action<IDictionary<string, object>> t, Func<IDictionary<string, object>, bool> condition) {
			Target = t;
			Condition = condition;
		}

		public virtual void Invoke(IDictionary<string, object> context) {
			if (!Condition(context))
				Target(context);
		}

	}

}
