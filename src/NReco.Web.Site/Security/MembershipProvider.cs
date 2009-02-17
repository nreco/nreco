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
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using System.Web.Security;
using NI.Data.Dalc;

namespace NReco.Web.Site.Security {
	
	public class MembershipProvider : System.Web.Security.MembershipProvider {
		bool _EnablePasswordReset = false;
		bool _EnablePasswordRetrieval = false;
		int _MaxInvalidPasswordAttempts = 3;
		int _MinRequiredNonAlphanumericCharacters = 0;
		int _MinRequiredPasswordLength = 4;
		int _PasswordAttemptWindow = 3;
		MembershipPasswordFormat _PasswordFormat = MembershipPasswordFormat.Clear;
		string _PasswordStrengthRegularExpression = ".*";
		bool _RequiresQuestionAndAnswer = false;
		bool _RequiresUniqueEmail = false;

		public override string ApplicationName { get; set; }
		public override bool EnablePasswordReset { get { return _EnablePasswordReset; } }
		public override bool EnablePasswordRetrieval { get { return _EnablePasswordRetrieval; } }
		public override int MaxInvalidPasswordAttempts { get { return _MaxInvalidPasswordAttempts; } }
		public override int MinRequiredNonAlphanumericCharacters { get { return _MinRequiredNonAlphanumericCharacters; } }
		public override int MinRequiredPasswordLength { get { return _MinRequiredPasswordLength; } }
		public override int PasswordAttemptWindow { get { return _PasswordAttemptWindow; } }
		public override MembershipPasswordFormat PasswordFormat { get { return _PasswordFormat; } }
		public override string PasswordStrengthRegularExpression { get { return _PasswordStrengthRegularExpression; } }
		public override bool RequiresQuestionAndAnswer { get { return _RequiresQuestionAndAnswer; } }
		public override bool RequiresUniqueEmail { get { return _RequiresUniqueEmail; } }

		public string MembershipStorageServiceName { get; set; }

		protected IUserStorage Storage {
			get {
				return WebManager.GetService<IUserStorage>(MembershipStorageServiceName);
			}
		}

		public MembershipProvider() {
			MembershipStorageServiceName = "userMembershipStorage";
		}

		public override bool ChangePassword(string username, string oldPassword, string newPassword) {
			var user = Storage.Load( new User(username) );
			if (user.Password == oldPassword) {
				user.Password = newPassword;
				return Storage.Update(user);
			}
			return false;
		}

		public override bool ChangePasswordQuestionAndAnswer(string username, string password, string newPasswordQuestion, string newPasswordAnswer) {
			var user = Storage.Load( new User(username) );
			if (user.Password == password) {
				user.PasswordQuestion = newPasswordQuestion;
				user.PasswordAnswer = newPasswordAnswer;
				return Storage.Update(user);
			}
			return false;
		}

		public override MembershipUser CreateUser(string username, string password, string email, string passwordQuestion, string passwordAnswer, bool isApproved, object providerUserKey, out MembershipCreateStatus status) {
			var user = new User();
			if (providerUserKey!=null)
				user.Id = providerUserKey;
			user.Username = username;
			user.Password = password;
			user.Email = email;
			user.PasswordQuestion = passwordQuestion;
			user.PasswordAnswer = passwordAnswer;
			user.IsApproved = isApproved;
			
			try {
				Storage.Create(user);
				status = MembershipCreateStatus.Success;
				return Storage.Load( new User(username) ).GetMembershipUser(Name);
			} catch (Exception ex) {
				status = MembershipCreateStatus.UserRejected;
				return null;
			}

		}

		public override bool DeleteUser(string username, bool deleteAllRelatedData) {
			return Storage.Delete(new User(username));
		}

		public override MembershipUserCollection FindUsersByEmail(string emailToMatch, int pageIndex, int pageSize, out int totalRecords) {
			throw new NotImplementedException();
		}

		public override MembershipUserCollection FindUsersByName(string usernameToMatch, int pageIndex, int pageSize, out int totalRecords) {
			throw new NotImplementedException();
		}

		public override MembershipUserCollection GetAllUsers(int pageIndex, int pageSize, out int totalRecords) {
			throw new NotImplementedException();
		}

		public override int GetNumberOfUsersOnline() {
			throw new NotImplementedException();
			/*TimeSpan onlineSpan = new TimeSpan(0, Membership.UserIsOnlineTimeWindow, 0);
			DateTime compareTime = DateTime.Now.Subtract(onlineSpan);

			return Dalc.RecordsCount(DalcUserSourceName, (QField)"last_activity_date">(QConst)compareTime);*/
		}

		public override string GetPassword(string username, string answer) {
			var user = Storage.Load( new User(username) );
			if (user.PasswordAnswer != answer)
				throw new Exception();
			return user.Password;
		}

		public override MembershipUser GetUser(string username, bool userIsOnline) {
			var user = Storage.Load( new User(username) );
			if (userIsOnline) {
				user.LastActivityDate = DateTime.Now;
				Storage.Update(user);
			}
			return user.GetMembershipUser(Name);	
		}

		public override MembershipUser GetUser(object providerUserKey, bool userIsOnline) {
			var user = Storage.Load(new User() { Id = providerUserKey });
			if (userIsOnline) {
				user.LastActivityDate = DateTime.Now;
				Storage.Update(user);
			}
			return user.GetMembershipUser(Name);	
		}

		public override string GetUserNameByEmail(string email) {
			throw new NotImplementedException();			
		}

		public override string ResetPassword(string username, string answer) {
			throw new NotImplementedException();
		}

		public override bool UnlockUser(string userName) {
			throw new NotImplementedException();
		}

		public override void UpdateUser(MembershipUser membershipUser) {
			var user = new User(membershipUser.UserName) {
				IsApproved = membershipUser.IsApproved,
				Comment = membershipUser.Comment,
				Email = membershipUser.Email
			};
			Storage.Update(user);
		}

		public override bool ValidateUser(string username, string password) {
			var user = Storage.Load(new User(username));
			return user!=null && user.Password == password;
		}
	}
}
