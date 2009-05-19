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

using NReco;
using NReco.Converting;
using NI.Winter;

namespace NReco.Winter {
	
	public class LocalValueFactory : ServiceProvider.LocalValueFactory {
		
		ITypeConverter _Converter = null;

		public ITypeConverter Converter {
			get { return _Converter; }
			set { _Converter = value; }
		}

		public LocalValueFactory(ServiceProvider srvPrv) : base(srvPrv) {
		}

		public LocalValueFactory(ServiceProvider srvPrv, ITypeConverter typeCnv) : base(srvPrv) {
			Converter = typeCnv;
		}

		protected override object ConvertTo(object o, Type toType) {
			// optimization: do not use type conversion mechanizm for conversions between primitive types 
			
			//if (o!=null && o.GetType().IsPrimitive && toType.IsPrimitive) {
				if (Converter!=null && o!=null && Converter.CanConvert(o.GetType(),toType))
					return Converter.Convert(o,toType);
				if (o!=null) {
					ITypeConverter cnv = ConvertManager.FindConverter(o.GetType(),toType);
					if (cnv!=null)
						return cnv.Convert(o,toType);
				} else {
					if (!toType.IsValueType)
						return null;
				}
			//}
			return base.ConvertTo(o, toType);
		}

	}
}
