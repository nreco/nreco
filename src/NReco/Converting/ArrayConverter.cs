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
	/// Array converter.
	/// </summary>
    public class ArrayConverter : ITypeConverter
    {

		public ArrayConverter() {
		}

		public virtual bool CanConvert(Type fromType, Type toType) {
			if (typeof(IEnumerable).IsAssignableFrom(fromType) && toType.IsArray) {
				// exception for string type
				if (fromType == typeof(string) && toType != typeof(char[]))
					return false;
				return true;
			}
			return false;
		}

		public virtual object Convert(object o, Type toType) {
			if (o is IEnumerable && toType.IsArray) {
				var elemType = toType.GetElementType();
				var enumList = (IEnumerable)o;
				var resList = new ArrayList();
				foreach (var elem in enumList)
					resList.Add(ConvertManager.ChangeType(elem, elemType));
				return resList.ToArray(elemType);
			}
			throw new InvalidCastException();
		}

	}

}
