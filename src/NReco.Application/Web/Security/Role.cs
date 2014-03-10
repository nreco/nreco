using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NReco.Application.Web.Security {
	
	/// <summary>
	/// Role data container.
	/// </summary>
	[Serializable]
	public class Role {
		string _Title = null;
		string _Name = null;
		IDictionary<string, object> _Data = null;

		/// <summary>
		/// Get or set role title
		/// </summary>
		public string Title {
			get { return _Title; }
			set { _Title = value; }
		}
		
		/// <summary>
		/// Get or set role name.
		/// </summary>
		public string Name {
			get { return _Name; }
			set { _Name = value; }
		}

		/// <summary>
		/// Get or set role additional data (name-value pairs)
		/// </summary>
		public IDictionary<string, object> Data {
			get { return _Data; }
			set { _Data = value; }
		}

		public Role() { }

		public Role(string name) {
			Name = name;
		}
	}

}
