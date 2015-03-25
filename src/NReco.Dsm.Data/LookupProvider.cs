using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Security;
using System.Threading;

namespace NReco.Dsm.Data {
	
	public class LookupProvider : ILookupProvider {

		Func<IDictionary,IEnumerable<IDictionary>> DataProvider;

		public string NotMatchedText { get; set; }

		public string ValueName { get; set; }

		public string TextName { get; set; }

		public LookupProvider(Func<IDictionary,IEnumerable<IDictionary>> dataProvider) {
			DataProvider = dataProvider;
			ValueName = "id";
			TextName = "value";
		}

		public object Resolve(object arg) {
			if (arg != null && !(arg is IDictionary)) {
				var argStr = Convert.ToString(arg);
				if (argStr.Length > 0) {
					var valContext = new Dictionary<string,object>() {
						{ValueName, arg}
					};
					var valRes = DataProvider(valContext);
					if (valRes!=null) {
						var firstEntry = valRes.FirstOrDefault();
						if (firstEntry!=null && firstEntry[TextName]!=null)
							return firstEntry[TextName];
					}
				}
				return NotMatchedText;
			}
			var prvContext = arg as IDictionary;
			return DataProvider( prvContext ?? new Dictionary<string,object>() );
		}
		
	}

	public interface ILookupProvider {
		object Resolve(object arg);
	}

}