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
using System.Collections;
using System.Text;
using System.Data;
using NReco.Converting;
using DbDataRow = System.Data.DataRow;

namespace NReco.OGNL.Helpers {
	
	public static class DataRow {

		public static DbDataRow Set(DbDataRow r, string fldName, object val) {
			r[fldName] = val ?? DBNull.Value;
			return r;
		}

		public static DbDataRow Set(DbDataRow r, IDictionary data) {
			foreach (DictionaryEntry entry in data) {
				Set(r, entry.Key.ToString(), entry.Value);
			}
			return r;
		}

		public static object Get(DbDataRow r, string fieldName) {
            if (r.RowState == DataRowState.Deleted)
                return r[fieldName, DataRowVersion.Original];
            return r[fieldName];
		}

		public static bool IsNull(object o) {
			return o == null || o == DBNull.Value;
		}

		public static IDictionary ToDictionary(DbDataRow r) {
			return ConvertManager.ChangeType<IDictionary>(r);
		}

	}
}
