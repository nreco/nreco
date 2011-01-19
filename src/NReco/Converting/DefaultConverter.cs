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
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Globalization;
using NReco.Collections;
using System.ComponentModel;

namespace NReco.Converting {

	/// <summary>
	/// Implements default converter routine (uses internal System.ComponentModel mechanism).
	/// </summary>
    public class DefaultConverter : ITypeConverter
    {

		public DefaultConverter() {
		}

		public virtual bool CanConvert(Type fromType, Type toType) {
			var fromTypeDescriptorConv = TypeDescriptor.GetConverter(fromType);
			if (fromTypeDescriptorConv != null && fromTypeDescriptorConv.CanConvertTo(toType))
				return true;
			var toTypeDescriptorConv = TypeDescriptor.GetConverter(toType);
			if (toTypeDescriptorConv != null && toTypeDescriptorConv.CanConvertFrom(fromType))
				return true;
			return false;
		}

		public virtual object Convert(object o, Type toType) {
			// maybe just simple types conversion
			var fromTypeDescriptorConv = TypeDescriptor.GetConverter(o);
			// to
			if (fromTypeDescriptorConv != null && fromTypeDescriptorConv.CanConvertTo(toType))
				try {
					//try context culture first
					return fromTypeDescriptorConv.ConvertTo(o, toType);
				} catch {
					//try invariant culture
					return fromTypeDescriptorConv.ConvertTo(null, CultureInfo.InvariantCulture, o, toType);
				}
			// from
			var toTypeDescriptorConv = TypeDescriptor.GetConverter(toType);
			if (o!=null && toTypeDescriptorConv != null && toTypeDescriptorConv.CanConvertFrom(o.GetType())) {
				try {
					//try context culture first
					return toTypeDescriptorConv.ConvertFrom(o);
				} catch {
					return toTypeDescriptorConv.ConvertFrom(null, CultureInfo.InvariantCulture, o);
				}
			}

			throw new InvalidCastException();
		}

	}

}
