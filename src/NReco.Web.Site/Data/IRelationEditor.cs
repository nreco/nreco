using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NReco.Web.Site.Data {
	
	/// <summary>
	/// Data relation editor service interface (used by UI relation editors)
	/// </summary>
	public interface IRelationEditor {
		void Set(object fromKey, IEnumerable toKeys);
		object[] GetToKeys(object fromKey);
	}
}
