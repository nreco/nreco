using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Transactions;

using System.Net.Mail;

namespace NReco.Application.Mail {
	
	/// <summary>
	/// Represents SendMail SMTP connection configuration
	/// </summary>
	public class SendMailSmtpConfiguration {
		public string Server { get; set; }
		public int Port { get; set; }
		public string User { get; set; }
		public string Password { get; set; }
		public bool Ssl { get; set; }

		public SendMailSmtpConfiguration() {
		}

	}
}
