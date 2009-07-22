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
using System.Reflection;
using System.Linq;
using System.Text;
using System.Web.Security;
using System.Data;
using NI.Data.Dalc;

namespace NReco.Web.Site.Security {
	
	public class DalcUserStorage : IUserStorage {
		public DalcManager DataManager { get; set; }
		public string UserSourceName { get; set; }
		public IDictionary<string, string> FieldsMapping { get; set; }

		public DalcUserStorage() {
		}

		protected string ResolveFieldName(string propName) {
			return FieldsMapping.ContainsKey(propName) ? FieldsMapping[propName] : propName;
		}

		public void Create(User user) {
			DataRow userRow = DataManager.Create(UserSourceName);
			
			var userProps = user.GetType().GetProperties();
			foreach (var prop in userProps)
				if (user.IsChanged(prop.Name)) {
					string key = ResolveFieldName(prop.Name);
					object value = prop.GetValue(user, null);
					if (userRow.Table.Columns.Contains(key) && !userRow.Table.Columns[key].AutoIncrement)
						userRow[key] = value;
				}
			DataManager.Update(userRow);
		}

		public User Load(User userSample) {
			IQueryNode condition = null;
			if (userSample.Id != null)
				condition = (QField)ResolveFieldName("Id") == (QConst)userSample.Id;
			else if (userSample.Username!=null)
				condition = (QField)ResolveFieldName("Username") == (QConst)userSample.Username;
			var data = new Hashtable();
			var q = new Query(UserSourceName, condition);
			if (DataManager.Dalc.LoadRecord(data, q)) {
				var user = new User();
				var userProps = user.GetType().GetProperties();
				foreach (var prop in userProps) {
					string key = ResolveFieldName(prop.Name);
					if (data.ContainsKey(key)) {
						object value = data[key];
						if (value == DBNull.Value)
							value = null;
						prop.SetValue(user, value, null);
					}
				}
				return user;
			}
			return null;
		}

		public bool Update(User user) {
			IQueryNode condition = (QField)ResolveFieldName("Username") == (QConst)user.Username;
			var userRow = DataManager.Load(new Query(UserSourceName, condition));
			if (userRow == null)
				return false;

			var userProps = user.GetType().GetProperties();
			foreach (var prop in userProps)
				if (user.IsChanged(prop.Name)) {
					string key = ResolveFieldName(prop.Name);
					object value = prop.GetValue(user, null);
					if (userRow.Table.Columns.Contains(key) && !userRow.Table.Columns[key].AutoIncrement)
						userRow[key] = value;
				}
			DataManager.Update(userRow);
			return true;
		}

		public bool Delete(User user) {
			var userRow = DataManager.Load(new Query(UserSourceName, (QField)ResolveFieldName("Username") == (QConst)user.Username));
			if (userRow == null)
				return false;
			DataManager.Delete(userRow);
			return true;
		}


	}
}
