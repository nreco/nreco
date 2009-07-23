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
using System.Collections.Specialized;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Web.Profile;

namespace NReco.Web.Site.Profile {
	
	public class ProfileProvider : System.Web.Profile.ProfileProvider {

		string _ApplicationName;

		public override string ApplicationName {
			get { return _ApplicationName; }
			set { _ApplicationName = value; }
		}

		public string ProfileStorageServiceName { get; set; }

		protected IProfileStorage Storage {
			get {
				return WebManager.GetService<IProfileStorage>(ProfileStorageServiceName);
			}
		}

		public ProfileProvider() {
		}

		public override void Initialize(string name, NameValueCollection config) {
			base.Initialize(name, config);
			ProfileStorageServiceName = GetConfigValue<string>(config["profileStorageServiceName"], ProfileStorageServiceName);

		}

		protected T GetConfigValue<T>(object o, T deflt) {
			if (o != null)
				return (T)Convert.ChangeType(o, typeof(T));
			return deflt;
		}


		public override int DeleteInactiveProfiles(ProfileAuthenticationOption authenticationOption, DateTime userInactiveSinceDate) {
			throw new NotImplementedException();
		}

		public override int DeleteProfiles(string[] usernames) {
			int delCount = 0;
			foreach (var username in usernames)
				if (Storage.Delete(username))
					delCount++;
			return delCount;
		}

		public override int DeleteProfiles(ProfileInfoCollection profiles) {
			int delCount = 0;
			foreach (ProfileInfo p in profiles) {
				if (Storage.Delete(p.UserName))
					delCount++;
			}
			return delCount;
		}

		public override ProfileInfoCollection FindInactiveProfilesByUserName(ProfileAuthenticationOption authenticationOption, string usernameToMatch, DateTime userInactiveSinceDate, int pageIndex, int pageSize, out int totalRecords) {
			throw new NotImplementedException();
		}

		public override ProfileInfoCollection FindProfilesByUserName(ProfileAuthenticationOption authenticationOption, string usernameToMatch, int pageIndex, int pageSize, out int totalRecords) {
			throw new NotImplementedException();
		}

		public override ProfileInfoCollection GetAllInactiveProfiles(ProfileAuthenticationOption authenticationOption, DateTime userInactiveSinceDate, int pageIndex, int pageSize, out int totalRecords) {
			throw new NotImplementedException();
		}

		public override ProfileInfoCollection GetAllProfiles(ProfileAuthenticationOption authenticationOption, int pageIndex, int pageSize, out int totalRecords) {
			throw new NotImplementedException();
		}

		public override int GetNumberOfInactiveProfiles(ProfileAuthenticationOption authenticationOption, DateTime userInactiveSinceDate) {
			throw new NotImplementedException();
		}


		public override SettingsPropertyValueCollection GetPropertyValues(SettingsContext context, SettingsPropertyCollection collection) {
			var username = (string)context["UserName"];
			var isAuthenticated = (bool)context["IsAuthenticated"];

			return Storage.LoadValues(username, collection);
		}

		public override void SetPropertyValues(SettingsContext context, SettingsPropertyValueCollection collection) {
			var username = (string)context["UserName"];
			var isAuthenticated = (bool)context["IsAuthenticated"];

			Storage.SaveValues(username, collection);
		}

	}
}
