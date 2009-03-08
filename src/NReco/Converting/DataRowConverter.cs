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
using System.Collections.Generic;
using System.Text;
using System.Data;
using NReco.Collections;

namespace NReco.Converting {

	/// <summary>
	/// DataRow converter.
	/// </summary>
    public class DataRowConverter : ITypeConverter
    {

		public DataRowConverter() {
		}

		public virtual bool CanConvert(Type fromType, Type toType) {
			if (!typeof(DataRow).IsAssignableFrom(fromType) &&
				!typeof(DataRowView).IsAssignableFrom(fromType))
				return false;
			if (toType == typeof(IDictionary))
				return true;
			if (toType==typeof(IDictionary<string,object>))
				return true;
			return false;
		}

		public virtual object Convert(object o, Type toType) {
			if (o is DataRowView)
				o = ((DataRowView)o).Row;
			if (o is DataRow) {
				if (toType == typeof(IDictionary))
					return new DictionaryWrapper<string,object>(
							new DataRowDictionaryWrapper( (DataRow)o) );
				if (toType == typeof(IDictionary<string,object>)) {
					return new DataRowDictionaryWrapper( (DataRow)o);
				}
			}
			throw new InvalidCastException();
		}

	}

}
