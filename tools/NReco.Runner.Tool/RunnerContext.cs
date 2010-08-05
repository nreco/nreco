#region License
/*
 * NReco library (http://code.google.com/p/nreco/)
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
using System.Linq;
using System.Text;

using NReco;

namespace NReco.Runner.Tool {

	public class RunnerContext : NameValueContext {

		public int ThreadIndex { get; private set; }

		public string Parameter { get; private set; }

		public RunnerContext(int threadIdx, string prm) {
			ThreadIndex = threadIdx;
			Parameter = prm;
		}
	}
}
