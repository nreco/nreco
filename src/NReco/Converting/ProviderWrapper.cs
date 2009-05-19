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

namespace NReco.Converting {
	
	/// <summary>
	/// Provider wrapper between generic interfaces
	/// </summary>
	/// <typeparam name="Context"></typeparam>
	/// <typeparam name="Result"></typeparam>
	public class ProviderWrapper<C1,R1,C2,R2> : IProvider<C2,R2> {
		public IProvider<C1, R1> UnderlyingProvider { get; set; }

		public ProviderWrapper() {}

		public ProviderWrapper(IProvider<C1, R1> underlyingPrv) {
			UnderlyingProvider = underlyingPrv;
		}

		public R2 Provide(C2 context) {
			C1 c;
			if ( !(context is C1) && context != null) {
				c = ConvertManager.ChangeType<C1>(context);
			} else {
				c = (C1)((object)context);
			}

			R1 res1 = UnderlyingProvider.Provide( c );
			R2 res2;
			if (!(res1 is R2) && res1 != null) {
				res2 = ConvertManager.ChangeType<R2>(res1);
			} else {
				res2 = (R2)((object)res1);
			}
			return res2;
		}

	}
}
