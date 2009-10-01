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

namespace NReco.Converting {

	/// <summary>
	/// Cast converter. Implements default routine.
	/// </summary>
    public class CastConverter : ITypeConverter
    {

		public CastConverter() {
		}

		public virtual bool CanConvert(Type fromType, Type toType) {
			// may be conversion is not needed
			if (toType == typeof(object))
				return true; // avoid TypeConvertor 'NotSupportedException'
			if (toType.IsAssignableFrom(fromType))
				return true;
			return false;
		}

		public virtual object Convert(object o, Type toType) {
			if (CanConvert(o.GetType(), toType))
				return o;
			throw new InvalidCastException();
		}

	}

}
