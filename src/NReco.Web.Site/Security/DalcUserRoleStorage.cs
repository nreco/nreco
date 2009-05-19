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
using System.Data;
using System.Linq;
using System.Text;
using NI.Data.Dalc;

namespace NReco.Web.Site.Security {
	
	public class DalcUserRoleStorage : IUserRoleStorage {
		public IDalc Dalc { get; set; }
		public string UserRoleSourceName { get; set; }
		
		/// <summary>
		/// Get or set DB fields mapping
		/// </summary>
		/// <remarks>
		/// This implementation uses only 2 fields: 'User' and 'Role'.
		/// </remarks>
		public IDictionary<string, string> FieldsMapping { get; set; }

		public DalcUserRoleStorage() {

		}

		protected string ResolveFieldName(string propName) {
			return FieldsMapping.ContainsKey(propName) ? FieldsMapping[propName] : propName;
		}

		public void Add(string userName, string roleName) {
			var data = new Hashtable();
			data[ResolveFieldName("User")] = userName;
			data[ResolveFieldName("Role")] = roleName;
			Dalc.Insert(data, UserRoleSourceName);
		}

		public bool Exists(string userName, string roleName) {
			return Dalc.RecordsCount(UserRoleSourceName,
				(QField)ResolveFieldName("User") == (QConst)userName &
				(QField)ResolveFieldName("Role") == (QConst)roleName) > 0;
		}

		public bool Remove(string userName, string roleName) {
			return Dalc.Delete(new Query(UserRoleSourceName,
				(QField)ResolveFieldName("User") == (QConst)userName &
				(QField)ResolveFieldName("Role") == (QConst)roleName)) > 0;
		}

		protected string[] Select(IQueryNode condition, string fldName) {
			DataSet ds = new DataSet();
			var q = new Query(UserRoleSourceName, condition);
			q.Fields = new string[] { fldName };
			Dalc.Load(ds, q);
			var values = new string[ds.Tables[UserRoleSourceName].Rows.Count];
			for (int i = 0; i < values.Length; i++)
				values[i] = (string)ds.Tables[UserRoleSourceName].Rows[i][fldName];
			return values;

		}

		public string[] GetUsers(string roleName) {
			return Select((QField)ResolveFieldName("Role") == (QConst)roleName, ResolveFieldName("User"));
		}

		public string[] GetRoles(string userName) {
			return Select((QField)ResolveFieldName("User") == (QConst)userName, ResolveFieldName("Role"));
		}

	}
}
