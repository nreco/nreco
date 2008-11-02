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
using System.Collections;
using System.Text;
using NReco.Logging;

namespace NReco.Providers {
	
	/// <summary>
	/// Lazy provider proxy.
	/// </summary>
	public class LazyProvider : IProvider {
		IProvider<string,IProvider> _InstanceProvider;
		string _ProviderName;
		ILog log = LogManager.GetLogger(typeof(LazyProvider));

		public string ProviderName {
			get { return _ProviderName; }
			set { _ProviderName = value; }
		}

		public IProvider<string, IProvider> InstanceProvider {
			get { return _InstanceProvider; }
			set { _InstanceProvider = value; }
		}

		public object Provide(object context) {
			IProvider prv = InstanceProvider.Provide(ProviderName);
			if (prv==null) {
				log.Error("Not found [providerName={0}]", ProviderName);
				throw new NullReferenceException("invalid provider name");
			}
			return prv.Provide(context);
		}

	}


}
