using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NReco;
using System.Web.Security;

namespace NReco.Web.Site.Security {

	/// <summary>
	/// Context user key value provider.
	/// </summary>
	public class UserKeyProvider : IProvider<object,object> {
		public object Provide(object context) {
			var user = Membership.GetUser();
			return user != null ? user.ProviderUserKey : null;
		}

	}
}
