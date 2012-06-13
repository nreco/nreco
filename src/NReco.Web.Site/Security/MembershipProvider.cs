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
using System.Collections.Specialized;
using System.Security.Cryptography;
using System.Linq;
using System.Text;
using System.Configuration;
using System.Configuration.Provider;
using System.Web.Security;
using System.Web;
using NI.Data.Dalc;
using NReco.Logging;

namespace NReco.Web.Site.Security {
	
	/// <summary>
	/// Membership provider based on underlying services from web context service provider.
	/// </summary>
	/// <remarks>
	/// This implementation of membership provider uses WebManager.GetService method for obtaining services.
	/// </remarks>
	public class MembershipProvider : System.Web.Security.MembershipProvider {
		static ILog log = LogManager.GetLogger(typeof(MembershipProvider));

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
		
		bool _RequiresIsApprovedForValidate = true;
		
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
		
		public bool RequiresIsApprovedForValidate { get { return _RequiresIsApprovedForValidate; } }
		
		/// <summary>
		/// Get or set user storage service name.
		/// </summary>
		public string UserStorageServiceName { get; set; }
		
		/// <summary>
		/// Get or set password encrypter service name (optional).
		/// </summary>
		public string PasswordEncrypterServiceName { get; set; }

		protected IUserStorage Storage {
			get {
				return WebManager.GetService<IUserStorage>(UserStorageServiceName);
			}
		}

		protected IPasswordEncrypter PasswordEncrypter {
			get {
				if (String.IsNullOrEmpty(PasswordEncrypterServiceName))
					throw new NotSupportedException("Password encrypter should be registered for using Hashed or Encrypted password formats.");
				return WebManager.GetService<IPasswordEncrypter>(PasswordEncrypterServiceName);
			}
		}

		public MembershipProvider() {
			UserStorageServiceName = "userMembershipStorage";
		}

		public override void Initialize(string name, NameValueCollection config) {
			base.Initialize(name, config);

			_EnablePasswordReset = GetConfigValue<bool>(config["enablePasswordReset"], _EnablePasswordReset);
			_EnablePasswordRetrieval = GetConfigValue<bool>(config["enablePasswordRetrieval"], _EnablePasswordRetrieval);
			_MaxInvalidPasswordAttempts = GetConfigValue<int>(config["maxInvalidPasswordAttempts"], _MaxInvalidPasswordAttempts);
			_MinRequiredNonAlphanumericCharacters = GetConfigValue<int>(config["minRequiredNonAlphanumericCharacters"], _MinRequiredNonAlphanumericCharacters);
			_MinRequiredPasswordLength = GetConfigValue<int>(config["minRequiredPasswordLength"], _MinRequiredPasswordLength);
			_PasswordAttemptWindow = GetConfigValue<int>(config["passwordAttemptWindow"], _PasswordAttemptWindow);
			if (config["passwordFormat"] != null)
				_PasswordFormat = (MembershipPasswordFormat)Enum.Parse(typeof(MembershipPasswordFormat), config["passwordFormat"], true);

			_PasswordStrengthRegularExpression = GetConfigValue<string>(config["passwordStrengthRegularExpression"], _PasswordStrengthRegularExpression);

			_RequiresQuestionAndAnswer = GetConfigValue<bool>(config["requiresQuestionAndAnswer"], _RequiresQuestionAndAnswer);
			_RequiresUniqueEmail = GetConfigValue<bool>(config["requiresUniqueEmail"], _RequiresUniqueEmail);

			_RequiresIsApprovedForValidate = GetConfigValue<bool>(config["requiresIsApprovedForValidate"], _RequiresIsApprovedForValidate);

			UserStorageServiceName = GetConfigValue<string>(config["userStorageServiceName"], UserStorageServiceName);
			PasswordEncrypterServiceName = GetConfigValue<string>(config["encrypterServiceName"], PasswordEncrypterServiceName);
		}

		protected T GetConfigValue<T>(object o, T deflt) {
			if (o != null)
				return (T)Convert.ChangeType(o, typeof(T));
			return deflt;
		}

		private string EncodePassword(string password) {
			if (PasswordFormat == MembershipPasswordFormat.Clear)
				return password;
			return PasswordEncrypter.Encrypt(password);
		}

		private string DecodePassword(string password) {
			switch (PasswordFormat) {
				case MembershipPasswordFormat.Hashed:
					throw new ProviderException("Cannot decode hashed password.");
				case MembershipPasswordFormat.Encrypted:
					password = PasswordEncrypter.Decrypt(password);
					break;
			}
			return password;
		}

		private bool CheckPassword(string pwd, string storedPwd) {
			switch (PasswordFormat) {
				case MembershipPasswordFormat.Hashed:
					pwd = PasswordEncrypter.Encrypt(pwd);
					break;
				case MembershipPasswordFormat.Encrypted:
					storedPwd = PasswordEncrypter.Decrypt(storedPwd);
					break;
			}
			return pwd == storedPwd;
		}


		public override bool ChangePassword(string username, string oldPassword, string newPassword) {
			log.Write(LogEvent.Debug, "Changing password for user (username={0})", username);
			var user = Storage.Load( new User(username) );
			if (CheckPassword(oldPassword, user.Password)) {
				user.Password = EncodePassword( newPassword );
                user.LastPasswordChangeDate = DateTime.Now;
				return Storage.Update(user);
			}
			return false;
		}

		public override bool ChangePasswordQuestionAndAnswer(string username, string password, string newPasswordQuestion, string newPasswordAnswer) {
			var user = Storage.Load( new User(username) );
			if (CheckPassword(password, user.Password)) {
				user.PasswordQuestion = newPasswordQuestion;
				user.PasswordAnswer = EncodePassword( newPasswordAnswer );
				return Storage.Update(user);
			}
			return false;
		}

		public override MembershipUser CreateUser(string username, string password, string email, string passwordQuestion, string passwordAnswer, bool isApproved, object providerUserKey, out MembershipCreateStatus status) {
			log.Write(LogEvent.Debug, "Creating user (username={0},password={1},email={2})", username, password, email);
			var user = new User();
			if (providerUserKey!=null)
				user.Id = providerUserKey;
			user.Username = username;
			user.Password = EncodePassword( password );
			if (email!=null)
				user.Email = email;
			if (passwordQuestion != null)
				user.PasswordQuestion = passwordQuestion;
			if (passwordAnswer!=null)
				user.PasswordAnswer = EncodePassword( passwordAnswer );
			user.IsApproved = isApproved;
			
			try {
				if (GetUser(user.Username, false) != null)
					throw new MembershipCreateUserException(MembershipCreateStatus.DuplicateUserName);
					
				if (RequiresUniqueEmail) {
					if (Storage.Load( new User() { Email = user.Email } )!=null)
						throw new MembershipCreateUserException(MembershipCreateStatus.DuplicateEmail);
				}

				Storage.Create(user);
				status = MembershipCreateStatus.Success;
				return Storage.Load( new User(username) ).GetMembershipUser(Name);
			} catch (Exception ex) {
				log.Write(LogEvent.Error, 
					new {Msg = String.Format("CreateUser failed: {0}",ex.Message), User = user, Exception = ex });
				status = ex is MembershipCreateUserException ?
					((MembershipCreateUserException)ex).StatusCode : MembershipCreateStatus.UserRejected;
				return null;
			}

		}

		public override bool DeleteUser(string username, bool deleteAllRelatedData) {
			log.Write(LogEvent.Debug, "Deleting user (username={0})", username);
			return Storage.Delete(new User(username));
		}
		
		protected MembershipUserCollection GetMembershipUsers(IEnumerable<User> users) {
			var res = new MembershipUserCollection();
			foreach (var usr in users)
				res.Add(usr.GetMembershipUser(Name));
			return res;		
		}
		
		public override MembershipUserCollection FindUsersByEmail(string emailToMatch, int pageIndex, int pageSize, out int totalRecords) {
			var users = Storage.LoadAll( new User() { Email = emailToMatch }, pageIndex, pageSize, out totalRecords);
			return GetMembershipUsers(users);
		}

		public override MembershipUserCollection FindUsersByName(string usernameToMatch, int pageIndex, int pageSize, out int totalRecords) {
			var users = Storage.LoadAll(new User() { Username = usernameToMatch }, pageIndex, pageSize, out totalRecords);
			return GetMembershipUsers(users);
		}

		public override MembershipUserCollection GetAllUsers(int pageIndex, int pageSize, out int totalRecords) {
			var users = Storage.LoadAll(new User(), pageIndex, pageSize, out totalRecords);
			return GetMembershipUsers(users);
		}

		public override int GetNumberOfUsersOnline() {
			throw new NotImplementedException();
			/*TimeSpan onlineSpan = new TimeSpan(0, Membership.UserIsOnlineTimeWindow, 0);
			DateTime compareTime = DateTime.Now.Subtract(onlineSpan);

			return Dalc.RecordsCount(DalcUserSourceName, (QField)"last_activity_date">(QConst)compareTime);*/
		}

		public override string GetPassword(string username, string answer) {
			if (PasswordFormat == MembershipPasswordFormat.Hashed)
				throw new ProviderException("Password is hashed.");

			var user = Storage.Load( new User(username) );
			if (user == null)
				throw new ProviderException("User does not exist.");
			if (CheckPassword(answer, user.PasswordAnswer))
				throw new ProviderException();
			return user.Password;
		}

		public override MembershipUser GetUser(string username, bool userIsOnline) {
            if (String.IsNullOrEmpty(username))
                return null;

			var cachedUser = GetUserFromCache(username);
			
			if (cachedUser != null)
				return cachedUser;

			var user = Storage.Load(new User(username));
			if (userIsOnline && user != null) 
				if (!user.LastActivityDate.HasValue || UpdateLastActivity(user.LastActivityDate.Value)) {
					user.LastActivityDate = DateTime.Now;
					Storage.Update(user);
				}
			if (user!=null) {
				var membershipUser = user.GetMembershipUser(Name);
				CacheUser(membershipUser, false);
				return membershipUser;
			}
			
			return null;	
		}

		public override MembershipUser GetUser(object providerUserKey, bool userIsOnline) {
			var user = Storage.Load(new User() { Id = providerUserKey });
			if (userIsOnline && user != null)
				if (!user.LastActivityDate.HasValue || UpdateLastActivity(user.LastActivityDate.Value)) {
					user.LastActivityDate = DateTime.Now;
					Storage.Update(user);
				}
			return user!=null ? user.GetMembershipUser(Name) : null;	
		}

		public override string GetUserNameByEmail(string email) {
			var user = Storage.Load(new User() { Email = email });
			return user != null ? user.Username : null;
		}

		public override string ResetPassword(string username, string answer) {
			if (!EnablePasswordReset)
				throw new NotImplementedException();
			
			var user = Storage.Load(new User(username));
			if (RequiresQuestionAndAnswer && user.PasswordAnswer!=answer)
				throw new MembershipPasswordException();
			
			// generate new pwd
			string newPassword = Membership.GeneratePassword( Math.Max(MinRequiredPasswordLength,6) ,MinRequiredNonAlphanumericCharacters);
			user.Password = EncodePassword(newPassword);
			Storage.Update(user);
			return newPassword;
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
			CacheUser(membershipUser, true);
		}

		public override bool ValidateUser(string username, string password) {
			var user = Storage.Load(new User(username));
			if (user!=null)
				CacheUser(user.GetMembershipUser(Name), false);
			var result = user != null && (user.IsApproved || !RequiresIsApprovedForValidate) && CheckPassword(password, user.Password);
            if (result) {
                user.LastActivityDate = DateTime.Now;
                Storage.Update(user);
            }
            return result;
		}

		protected bool UpdateLastActivity(DateTime lastActivityDate) {
			int timeWindow = Membership.UserIsOnlineTimeWindow > 1 ? Membership.UserIsOnlineTimeWindow - 1 : Membership.UserIsOnlineTimeWindow;
			return lastActivityDate.AddMinutes(timeWindow) < DateTime.Now;
		}

		protected MembershipUser GetUserFromCache(string username) {
			if (HttpContext.Current != null)
				return HttpContext.Current.Items[typeof(MembershipProvider).FullName + username] as MembershipUser;
			return null;
		}

		protected void CacheUser(MembershipUser user, bool update) {
			if (HttpContext.Current != null) {
				var key = typeof(MembershipProvider).FullName + user.UserName;
				if (!update || HttpContext.Current.Items.Contains(key))
					HttpContext.Current.Items[key] = user;
			}
		}

	}
}
