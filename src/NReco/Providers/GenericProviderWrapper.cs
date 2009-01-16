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
	/// Provider wrapper between non-generic and generic interfaces
	/// </summary>
	/// <typeparam name="Context"></typeparam>
	/// <typeparam name="Result"></typeparam>
	public class GenericProviderWrapper<Context,ResT> : IProvider<Context,ResT> {
		IProvider _UnderlyingProvider;
		ITypeConverter _TypeConverter = null;

		public ITypeConverter TypeConverter {
			get { return _TypeConverter; }
			set { _TypeConverter = value; }
		}

		public IProvider UnderlyingProvider {
			get { return _UnderlyingProvider; }
			set { _UnderlyingProvider = value; }
		}

		public GenericProviderWrapper() {}

		public GenericProviderWrapper(IProvider underlyingPrv) {
			UnderlyingProvider = underlyingPrv;
		}

		public ResT Provide(Context context) {
			object res = UnderlyingProvider.Provide(context);
			if (res is ResT) return (ResT)res;
			if (res==null)
				return typeof(ResT).IsValueType ? default(ResT) : (ResT)res;
			if (TypeConverter!=null && TypeConverter.CanConvert(res.GetType(),typeof(ResT)))
				return (ResT)TypeConverter.Convert(res,typeof(ResT));
			throw new InvalidCastException();
		}

	}
}
