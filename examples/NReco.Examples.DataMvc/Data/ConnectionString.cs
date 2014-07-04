using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using NI.Ioc;

namespace NReco.Examples.DataMvc.Data {
	public class ConnectionString : IFactoryComponent {
		public string ConnectionStringTemplate { get; set; }

		public object GetObject() {
			return String.Format(ConnectionStringTemplate, System.IO.Path.GetTempPath() );
		}

		public Type GetObjectType() {
			return typeof(string);
		}
	}
}