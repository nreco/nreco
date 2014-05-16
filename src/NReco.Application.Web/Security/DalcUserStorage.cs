#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2014 Vitaliy Fedorchenko
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
using NI.Data;
using NReco.Collections;

namespace NReco.Application.Web.Security {
	
	/// <summary>
	/// DALC based user data storage
	/// </summary>
	public class DalcUserStorage : IUserStorage {

		/// <summary>
		/// Get or set DALC manager used for loading and updating user info
		/// </summary>
		public DataRowDalcMapper DataManager { get; set; }

		/// <summary>
		/// Get or set source name for updating user info
		/// </summary>
		public string UserSourceName { get; set; }
		
		/// <summary>
		/// Field names mapping (User object properties to source name field names)
		/// </summary>
		public IDictionary<string, string> FieldsMapping { get; set; }

		string _LoadUserSourceName = null;
		
		/// <summary>
		/// Get or set source name for loading user info
		/// </summary>
		public string LoadUserSourceName {
			get { return _LoadUserSourceName ?? UserSourceName; }
			set { _LoadUserSourceName = value; }
		}

		public DalcUserStorage() {
		}

		protected string ResolveFieldName(string propName) {
			return FieldsMapping.ContainsKey(propName) ? FieldsMapping[propName] : propName;
		}

		public virtual void Create(User user) {
			DataRow userRow = DataManager.Create(UserSourceName);
			
			var userProps = user.GetType().GetProperties();
			foreach (var prop in userProps)
				if (user.IsChanged(prop.Name)) {
					string key = ResolveFieldName(prop.Name);
					object value = prop.GetValue(user, null);
					if (userRow.Table.Columns.Contains(key) && !userRow.Table.Columns[key].AutoIncrement)
						userRow[key] = value ?? DBNull.Value;
				}
			DataManager.Update(userRow);
		}
		
		protected Query GetUserQueryBySample(User userSample) {
			var condition = new QueryGroupNode(QueryGroupNodeType.And);
			if (userSample.Id != null)
				condition.Nodes.Add( (QField)ResolveFieldName("Id") == new QConst(userSample.Id) );
			else if (userSample.Username != null)
				condition.Nodes.Add( (QField)ResolveFieldName("Username") == (QConst)userSample.Username );
			else if (userSample.Email != null)
				condition.Nodes.Add( (QField)ResolveFieldName("Email") == (QConst)userSample.Email );
			return new Query(LoadUserSourceName, condition);
		}
		
		protected void SetUserProps(User user, IDictionary data) {
			var userProps = user.GetType().GetProperties();
			foreach (var prop in userProps) {
				string key = ResolveFieldName(prop.Name);
				if (data.Contains(key)) {
					object value = data[key];
					if (value == DBNull.Value)
						value = null;
					prop.SetValue(user, value, null);
				}
			}
		
		}
		
		public virtual User Load(User userSample) {
			var q = GetUserQueryBySample(userSample);
			var data = DataManager.Dalc.LoadRecord(q);
			if (data!=null) {
				var user = new User();
				SetUserProps(user, data);
				return user;
			}
			return null;
		}

		public virtual IEnumerable<User> LoadAll(User userSample, int pageIndex, int pageSize, out int totalRecords) {
			var q = GetUserQueryBySample(userSample);
			totalRecords = DataManager.Dalc.RecordsCount( q );
			if (totalRecords==0)
				return new User[0];
			
			q.StartRecord = pageIndex*pageSize;
			q.RecordCount = pageSize;
			var usersTbl = DataManager.LoadAll(q);
			var res = new List<User>();
			
			foreach (DataRow userRow in usersTbl.Rows) {
				var user = new User();
				SetUserProps(user, new DictionaryWrapper<string,object>( new DataRowDictionaryWrapper(userRow) ) );
				res.Add(user);
			}
			
			return res;
		}

		protected bool EnsureUserId(User user) {
			// if user id is unknown, lets resolve it using Load procedure
			if (user.Id == null) {
				var loadedUser = Load(user);
				if (loadedUser.Id == null)
					return false;
				user.Id = loadedUser.Id;
			}
			return true;
		}

		public virtual bool Update(User user) {
			if (!EnsureUserId(user)) return false;
			QueryNode condition = (QField)ResolveFieldName("Id") == new QConst(user.Id);
			var userRow = DataManager.Load(new Query(UserSourceName, condition));
			if (userRow == null)
				return false;

			var userProps = user.GetType().GetProperties();
			foreach (var prop in userProps)
				if (user.IsChanged(prop.Name)) {
					string key = ResolveFieldName(prop.Name);
					object value = prop.GetValue(user, null);
					if (userRow.Table.Columns.Contains(key) && !userRow.Table.Columns[key].AutoIncrement)
						userRow[key] = value ?? DBNull.Value;
				}
			DataManager.Update(userRow);
			return true;
		}

		public virtual bool Delete(User user) {
			if (!EnsureUserId(user)) return false;
			var userRow = DataManager.Load(new Query(UserSourceName, (QField)ResolveFieldName("Id") == new QConst(user.Id) ));
			if (userRow == null)
				return false;
			DataManager.Delete(userRow);
			return true;
		}


	}
}
