using System;
using System.Collections.Generic;
using System.Text;
using System.Configuration;

using NI.Common;
using NI.Winter;
using NReco;
using NReco.Logging;
using NReco.Converting;

namespace NReco.Examples.Hello {
	class Program {
		static void Main(string[] args) {
			LogManager.Configure( new TraceLogger() );
			IComponentsConfig config = ConfigurationSettings.GetConfig("components") as IComponentsConfig;
			INamedServiceProvider srvPrv = new NReco.Winter.ServiceProvider(config);

			IOperation zz = srvPrv.GetService("ZZ") as IOperation;

			IOperation<IDictionary<string,object>> a = srvPrv.GetService("A") as IOperation<IDictionary<string,object>>;
			NameValueContext c = new NameValueContext();
			Console.WriteLine("NReco 'hello world' sample. Try to type 'hello' or 'what is your name', 'die' for exit");

			while (true) {
				Console.Write("you> ");
				c["msg"] = Console.ReadLine();
				Console.Write("nreco> ");
				a.Execute(c);
				if (c.ContainsKey("state") && Convert.ToString( c["state"] )=="exit")
					return;
			}
		}
	}
}
