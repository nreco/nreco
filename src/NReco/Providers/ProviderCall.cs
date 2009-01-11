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

namespace NReco.Providers {

	/// <summary>
	/// Provider wrapper that can substitute context and/or result for underlying provider.  
	/// </summary>
	public class ProviderCall : IProvider {
		IProvider _Provider;
		IProvider _ContextFilter = null;
		IProvider _ResultFilter = null;

		public IProvider Provider {
			get { return _Provider; }
			set { _Provider = value; }
		}

		public IProvider ContextFilter {
			get { return _ContextFilter; }
			set { _ContextFilter = value; }
		}

		public IProvider ResultFilter {
			get { return _ResultFilter; }
			set { _ResultFilter = value; }
		}

		public ProviderCall() { }

		public ProviderCall(IProvider prv) {
			Provider = prv;
		}

		public object Provide(object context) {
			object prvContext = context;
			if (ContextFilter!=null)
				prvContext = ContextFilter.Provide(prvContext);
			object res = Provider.Provide(prvContext);
			if (ResultFilter!=null)
				res = ResultFilter.Provide(res);
			return res;
		}

	}

}
