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
using NReco.Converting;

namespace NReco.Providers {
	
	/// <summary>
	/// Provider wrapper between generic and non-generic interfaces
	/// </summary>
	/// <typeparam name="Context"></typeparam>
	/// <typeparam name="Result"></typeparam>
	public class ProviderWrapper<ContextT,ResT> : IProvider {
		IProvider<ContextT,ResT> _UnderlyingProvider;

		public IProvider<ContextT,ResT> UnderlyingProvider {
			get { return _UnderlyingProvider; }
			set { _UnderlyingProvider = value; }
		}

		public ProviderWrapper() {}

		public ProviderWrapper(IProvider<ContextT,ResT> underlyingPrv) {
			UnderlyingProvider = underlyingPrv;
		}

		public object Provide(object context) {
			if (!(context is ContextT) && context != null) {
				context = ConvertManager.ChangeType(context, typeof(ContextT));
			}

			object res = UnderlyingProvider.Provide( (ContextT) context);
			return res;
		}

	}
}
