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

namespace NReco.Composition {
	
	/// <summary>
	/// Lazy provider proxy.
	/// </summary>
	public class LazyProvider<C,R> : IProvider<C,R> {
		IProvider<string,IProvider<C,R>> _InstanceProvider;
		string _ProviderName;
		static ILog log = LogManager.GetLogger(typeof(LazyProvider));

		public string ProviderName {
			get { return _ProviderName; }
			set { _ProviderName = value; }
		}

		public IProvider<string, IProvider<C, R>> InstanceProvider {
			get { return _InstanceProvider; }
			set { _InstanceProvider = value; }
		}

		public R Provide(C context) {
			var prv = InstanceProvider.Provide(ProviderName);
			if (prv==null) {
				log.Write(
					LogEvent.Error,
					new{Action="getting real instance",Msg="not found",ProviderName=ProviderName}
				);
				throw new NullReferenceException("invalid provider name");
			}
			return prv.Provide(context);
		}

	}

	public class LazyProvider : LazyProvider<object, object> {
		public LazyProvider() { }
	}

}
