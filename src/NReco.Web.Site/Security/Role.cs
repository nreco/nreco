using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NReco.Web.Site.Security {
	
	/// <summary>
	/// Role data container.
	/// </summary>
	[Serializable]
	public class Role {
		string _Description = null;
		string _Name = null;

		public string Description {
			get { return _Description; }
			set { _Description = value; }
		}
		
		public string Name {
			get { return _Name; }
			set { _Name = value; }
		}

		public Role(string name) {
			Name = name;
		}
	}

}
