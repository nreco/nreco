using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Security.Principal;
using System.Web;
using NReco;
using System.Web.Security;

namespace NReco.Application.Web.Security {

	/// <summary>
	/// Web security-related helper functions
	/// </summary>
	public class SecurityHelper {

		public static object GetUserKey() {
			return GetUserKey(null);
		}

		public static object GetUserKey(string userName) {
			return GetUserKey(userName, null);
		}

		public static object GetUserKey(string userName, object defaultKeyValue) {
			if (HttpContext.Current == null)
				return defaultKeyValue;
			var user = userName != null ? Membership.GetUser(userName,false) : Membership.GetUser(HttpContext.Current.User.Identity.Name, false);
			return user != null ? user.ProviderUserKey : defaultKeyValue;
		}

	}


}
