using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Threading;
using System.Web;

using NReco;
using NReco.Logging;

namespace NReco.Application.Console {
	public class UrlTester : IOperation<object> {

		static ILog log = LogManager.GetLogger(typeof(UrlTester));

		public TimeSpan PingPeriod { get; set; }
		public string[] Addresses { get; set; }

		public UrlTester() {
			PingPeriod = new TimeSpan(0, 5, 0);
		}

		public void Execute(object context) {

			for (; ; ) {
				foreach (var url in Addresses) {
					try {
						var req = WebRequest.Create(url);
						var response = req.GetResponse();
						log.Write(LogEvent.Info, "GET result for URL={0}: length={1}", url, response.ContentLength);
						response.Close();
					} catch (Exception ex) {
						log.Write(LogEvent.Error, "GET failed for URL={0}, reason: {1}", url, ex.Message);
					}
				}

				Thread.Sleep( PingPeriod );
			}

		}

	}
}
