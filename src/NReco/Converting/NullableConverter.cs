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
using NReco.Collections;
using System.ComponentModel;

namespace NReco.Converting {

	/// <summary>
	/// Implements converter routine for nullable types.
	/// </summary>
    public class NullableConverter : ITypeConverter
    {

		public NullableConverter() {
		}

		public static bool IsNullable(Type t) {
			return t.IsGenericType && t.GetGenericTypeDefinition() == typeof(Nullable<>);
		}

		public virtual bool CanConvert(Type fromType, Type toType) {
			// handle only convertions "to nullable" for now
			if (IsNullable(toType))
				return true;
			return false;
		}

		public virtual object Convert(object o, Type toType) {
			if (IsNullable(toType)) {
				var underlyingToType = Nullable.GetUnderlyingType(toType);
				var underlyingValue = ConvertManager.ChangeType(o, underlyingToType);
				return Activator.CreateInstance(toType, underlyingValue);
			}
			throw new InvalidCastException();
		}

	}

}
