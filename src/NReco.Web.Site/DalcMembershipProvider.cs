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

namespace NReco.Web.Site {
	
	public class DalcMembershipProvider : System.Web.Security.MembershipProvider {
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

		public string DalcName { get; set; }
		public string DalcUserSourceName { get; set; }

		protected IDalc Dalc {
			get {
				return WebManager.GetService<IDalc>(DalcName);
			}
		}

		public DalcMembershipProvider() {
			DalcName = "db";
			DalcUserSourceName = "accounts";
		}

		public override bool ChangePassword(string username, string oldPassword, string newPassword) {
			int count = Dalc.Update( 
				new Hashtable { {"password",newPassword } },
				new Query(DalcUserSourceName, 
					(QField)"username"==(QConst)username & (QField)"password"==(QConst)oldPassword ) );
			return count>0 ? true : false;
		}

		public override bool ChangePasswordQuestionAndAnswer(string username, string password, string newPasswordQuestion, string newPasswordAnswer) {
			int count = Dalc.Update( 
				new Hashtable { 
					{"password_question",newPasswordQuestion },
					{"password_answer",newPasswordAnswer }
				},
				new Query(DalcUserSourceName, 
					(QField)"username"==(QConst)username & (QField)"password"==(QConst)password ) );
			return count>0 ? true : false;
		}

		public override MembershipUser CreateUser(string username, string password, string email, string passwordQuestion, string passwordAnswer, bool isApproved, object providerUserKey, out MembershipCreateStatus status) {
			var data = new Hashtable {
				{"username", username},
				{"password", password},
				{"email", email},
				{"password_question", passwordQuestion},
				{"password_answer", passwordAnswer},
				{"is_approved", isApproved}
			};
			try {
				Dalc.Insert(data, DalcUserSourceName);
				status = MembershipCreateStatus.Success;
				return GetUser(username, false);
			} catch (Exception ex) {
				status = MembershipCreateStatus.UserRejected;
				return null;
			}

		}

		public override bool DeleteUser(string username, bool deleteAllRelatedData) {
			return Dalc.Delete(
				new Query(DalcUserSourceName, (QField)"username" == (QConst)username))>0;
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
			TimeSpan onlineSpan = new TimeSpan(0, Membership.UserIsOnlineTimeWindow, 0);
			DateTime compareTime = DateTime.Now.Subtract(onlineSpan);

			return Dalc.RecordsCount(DalcUserSourceName, (QField)"last_activity_date">(QConst)compareTime);
		}

		public override string GetPassword(string username, string answer) {
			var data = new Hashtable();
			var q = new Query(DalcUserSourceName, (QField)"username" == (QConst)username & (QField)"password_answer" == (QConst)answer );
			if (Dalc.LoadRecord(data,q)) {
				return data["password"].ToString();
			}
			throw new Exception();
		}

		public override MembershipUser GetUser(string username, bool userIsOnline) {
			return LoadMembershipUser((QField)"username" == (QConst)username, userIsOnline);	
		}

		public override MembershipUser GetUser(object providerUserKey, bool userIsOnline) {
			return LoadMembershipUser((QField)"id" == (QConst)providerUserKey, userIsOnline);	
		}

		protected MembershipUser LoadMembershipUser(IQueryNode condition, bool userIsOnline) {
			var data = new Hashtable();
			var q = new Query(DalcUserSourceName, condition);
			if (Dalc.LoadRecord(data, q) ) {
				var user = new MembershipUser(
					this.Name,
					Convert.ToString(data["username"]),
					data["id"],
					Convert.ToString(data["email"]),
					Convert.ToString(data["password_question"]),
					Convert.ToString(data["comment"]),
					Convert.ToBoolean(data["is_approved"]),
					false,
					GetDateTime(data["creation_date"]),
					GetDateTime(data["last_login_date"]),
					GetDateTime(data["last_activity_date"]),
					GetDateTime(data["last_pwd_change_date"]), DateTime.MinValue);
				if (userIsOnline)
					Dalc.Update( new Hashtable {{"last_activity_date", DateTime.Now} }, q );
				return user;
			}
			throw new Exception();
		}

		protected DateTime GetDateTime(object o) {
			return o != null && o != DBNull.Value ? Convert.ToDateTime(o) : DateTime.MinValue;
		}

		public override string GetUserNameByEmail(string email) {
			var data = new Hashtable();
			if (Dalc.LoadRecord(data,new Query(DalcUserSourceName, (QField)"email" == (QConst)email))) {
				return data["username"].ToString();
			}
			throw new Exception();			
		}

		public override string ResetPassword(string username, string answer) {
			throw new NotImplementedException();
		}

		public override bool UnlockUser(string userName) {
			throw new NotImplementedException();
		}

		public override void UpdateUser(MembershipUser user) {
			var data = new Hashtable();
			data["is_approved"] = user.IsApproved;
			data["comment"] = user.Comment;
			data["email"] = user.Email;
			Dalc.Update(data, new Query(DalcUserSourceName, (QField)"username" == (QConst)user.UserName));
		}

		public override bool ValidateUser(string username, string password) {
			var count = Dalc.RecordsCount(DalcUserSourceName,
				(QField)"username" == (QConst)username & (QField)"password" == (QConst)password);
			return count > 0;
		}
	}
}
