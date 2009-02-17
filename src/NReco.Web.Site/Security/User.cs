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
using System.Linq;
using System.Text;
using System.Web.Security;

namespace NReco.Web.Site.Security {
	
	[Serializable]
	public class User {
		IDictionary<string, bool> FieldChanged = new Dictionary<string, bool>();

		object _Id = null;
		string _Username = null;
		string _Password = null;
		string _Email = null;
		string _PasswordAnswer = null;
		string _PasswordQuestion = null;
		string _Comment = null;
		DateTime? _CreationDate = null;
		DateTime? _LastLoginDate = null;
		DateTime? _LastActivityDate = null;
		DateTime? _LastPasswordChangeDate = null;
		DateTime? _LastLockoutDate = null;
		bool _IsApproved = true;

		public object Id {
			get { return _Id; }
			set { _Id = value; FieldChanged["Id"] = true; }
		}

		public string Username {
			get { return _Username; }
			set { _Username = value; FieldChanged["Username"] = true; }
		}
		
		public string Password {
			get { return _Password; }
			set { _Password = value; FieldChanged["Password"] = true; }
		}

		public string Email {
			get { return _Email; }
			set { _Email = value; FieldChanged["Email"] = true; }
		}

		public string PasswordAnswer {
			get { return _PasswordAnswer; }
			set { _PasswordAnswer = value; FieldChanged["PasswordAnswer"] = true; }
		}

		public string PasswordQuestion {
			get { return _PasswordQuestion; }
			set { _PasswordQuestion = value; FieldChanged["PasswordQuestion"] = true; }
		}

		public string Comment {
			get { return _Comment; }
			set { _Comment = value; FieldChanged["Comment"] = true; }
		}

		public DateTime? CreationDate {
			get { return _CreationDate; }
			set { _CreationDate = value; FieldChanged["CreationDate"] = true; } 
		}

		public DateTime? LastLoginDate {
			get { return _LastLoginDate; }
			set { _LastLoginDate = value; FieldChanged["LastLoginDate"] = true; }
		}

		public DateTime? LastActivityDate {
			get { return _LastActivityDate; }
			set { _LastActivityDate = value; FieldChanged["LastActivityDate"] = true; }
		}

		public DateTime? LastPasswordChangeDate {
			get { return _LastPasswordChangeDate; }
			set { _LastPasswordChangeDate = value; FieldChanged["LastPasswordChangeDate"] = true; }
		}

		public DateTime? LastLockoutDate {
			get { return _LastLockoutDate; }
			set { _LastLockoutDate = value; FieldChanged["LastLockoutDate"] = true; }
		}

		public bool IsApproved {
			get { return _IsApproved; }
			set { _IsApproved = value; FieldChanged["IsApproved"] = true; }
		}

		public User() {
		}

		public User(string username) {
			_Username = username;
		}

		public void AcceptChanges() {
			FieldChanged.Clear();
		}

		public bool IsChanged(string fldName) {
			return FieldChanged.ContainsKey(fldName) ? FieldChanged[fldName] : false;
		}

		public MembershipUser GetMembershipUser(string prvName) {
			return new MembershipUser(
					prvName, Username, Id, Email, PasswordQuestion, Comment, IsApproved, false,
					DefaultDateTime(CreationDate),
					DefaultDateTime(LastLoginDate),
					DefaultDateTime(LastActivityDate),
					DefaultDateTime(LastPasswordChangeDate),
					DefaultDateTime(LastLockoutDate)
				);
		}

		protected DateTime DefaultDateTime(DateTime? dt) {
			return dt.HasValue ? dt.Value : default(DateTime);
		}

	}
}
