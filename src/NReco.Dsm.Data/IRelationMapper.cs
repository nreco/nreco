using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NReco.Dsm.Data {
	
	/// <summary>
	/// Data relation mapper interface
	/// </summary>
	public interface IRelationMapper {
		void Update(object fromKey, IEnumerable toKeys);
		object[] Load(object fromKey);
	}
}
