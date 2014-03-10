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
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using System.Web.Security;

namespace NReco.Application.Web.Security {
	
	public class RoleProvider : System.Web.Security.RoleProvider {

		public override string ApplicationName { get; set; }

		public string RoleStorageServiceName { get; set; }
		public string UserRoleStorageServiceName { get; set; }

		protected IRoleStorage RoleStorage {
			get {
				if (RoleStorageServiceName != null)
					return AppContext.ComponentFactory.GetComponent(RoleStorageServiceName, typeof(IRoleStorage)) as IRoleStorage;
				return AppContext.ComponentFactory.GetService(typeof(IRoleStorage)) as IRoleStorage;
			}
		}

		protected IUserRoleStorage UserRoleStorage {
			get {
				if (UserRoleStorageServiceName != null)
					return AppContext.ComponentFactory.GetComponent(UserRoleStorageServiceName, typeof(IUserRoleStorage)) as IUserRoleStorage;
				return AppContext.ComponentFactory.GetService(typeof(IUserRoleStorage)) as IUserRoleStorage;
			}
		}

		public RoleProvider() {
		}

		public override void Initialize(string name, NameValueCollection config) {
			base.Initialize(name, config);

			if (!String.IsNullOrEmpty(config["roleStorageServiceName"]))
				RoleStorageServiceName = config["roleStorageServiceName"];
			if (!String.IsNullOrEmpty(config["userRoleStorageServiceName"]))
				UserRoleStorageServiceName = config["userRoleStorageServiceName"];
		}

		public override void AddUsersToRoles(string[] usernames, string[] roleNames) {
			foreach (string userName in usernames) {
				string[] currentRoles = UserRoleStorage.GetRoles(userName);
				foreach (string roleName in roleNames)
					if (Array.IndexOf<string>(currentRoles, roleName) < 0)
						UserRoleStorage.Add(userName, roleName);
			}
		}

		public override void CreateRole(string roleName) {
			RoleStorage.Create(new Role(roleName));
		}

		public override bool DeleteRole(string roleName, bool throwOnPopulatedRole) {
			return RoleStorage.Delete(new Role(roleName));
		}

		public override string[] FindUsersInRole(string roleName, string usernameToMatch) {
			throw new NotImplementedException();
		}

		public override string[] GetAllRoles() {
			var q = from role in RoleStorage.LoadAll() select role.Name;
			return q.ToArray<string>();
		}

		public override string[] GetRolesForUser(string username) {
			return UserRoleStorage.GetRoles(username);
		}

		public override string[] GetUsersInRole(string roleName) {
			return UserRoleStorage.GetUsers(roleName);
		}

		public override bool IsUserInRole(string username, string roleName) {
			return UserRoleStorage.Exists(username, roleName);
		}

		public override void RemoveUsersFromRoles(string[] usernames, string[] roleNames) {
			foreach (string userName in usernames)
				foreach (string roleName in roleNames)
					UserRoleStorage.Remove(userName, roleName);
		}

		public override bool RoleExists(string roleName) {
			return RoleStorage.Load(roleName)!=null;
		}
	}

}
