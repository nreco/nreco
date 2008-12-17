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
using System.Xml;
using System.Configuration;

namespace NReco.Web {
	
	/// <summary>
	/// Web manager configuration.
	/// </summary>
	public class WebManagerCfg {
		string _ServiceProviderContextKey = "__service_provider";
		string _ActionDispatcherName = "webActionDispatcher";
		string _HttpRootBasePath = null;

		public string ServiceProviderContextKey {
			get { return _ServiceProviderContextKey; }
			set { _ServiceProviderContextKey = value; }
		}

		public string ActionDispatcherName {
			get { return _ActionDispatcherName; }
			set { _ActionDispatcherName = value; }
		}

		public string HttpRootBasePath {
			get { return _HttpRootBasePath; }
			set { _HttpRootBasePath = value; }
		}

		public WebManagerCfg() {

		}

	}
}
