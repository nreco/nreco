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
using NI.Data.Dalc;

namespace NReco.Web.Site.Security {
	
	public class DalcUserStorage : IUserStorage {
		public IDalc Dalc { get; set; }
		public string UserSourceName { get; set; }
		public IDictionary<string, string> FieldsMapping { get; set; }

		public DalcUserStorage() {
		}

		protected string ResolveFieldName(string propName) {
			return FieldsMapping.ContainsKey(propName) ? FieldsMapping[propName] : propName;
		}

		public void Create(User user) {
			var data = new Hashtable();
			var userProps = user.GetType().GetProperties();
			foreach (var prop in userProps)
				if (user.IsChanged(prop.Name)) {
					string key = ResolveFieldName(prop.Name);
					object value = prop.GetValue(user, null);
					data[key] = value;
				}
			Dalc.Insert(data, UserSourceName);
		}

		public User Load(User userSample) {
			IQueryNode condition = null;
			if (userSample.Id != null)
				condition = (QField)ResolveFieldName("Id") == (QConst)userSample.Id;
			else if (userSample.Username!=null)
				condition = (QField)ResolveFieldName("Username") == (QConst)userSample.Username;
			var data = new Hashtable();
			var q = new Query(UserSourceName, condition);
			if (Dalc.LoadRecord(data, q)) {
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
			var changeset = new Hashtable();
			IQueryNode condition = (QField)ResolveFieldName("Username") == (QConst)user.Username;
			
			var userProps = user.GetType().GetProperties();
			foreach (var prop in userProps)
				if (user.IsChanged(prop.Name)) {
					string key = ResolveFieldName(prop.Name);
					object value = prop.GetValue(user, null);
					changeset[key] = value;
				}
			return Dalc.Update(changeset, new Query(UserSourceName, condition))>0;
		}

		public bool Delete(User user) {
			return Dalc.Delete(
				new Query(UserSourceName, (QField)ResolveFieldName("Username") == (QConst)user.Username)) > 0;
		}


	}
}
