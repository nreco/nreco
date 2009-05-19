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

namespace NReco.Composition {
	
	/// <summary>
	/// Context provider - simply returns passed context object. 
	/// </summary>
	public class ContextProvider : IProvider<object,object> {
		public readonly static ContextProvider Instance = new ContextProvider();

		public ContextProvider() {}

		public object Provide(object context) {
			return context;
		}
	}
}
