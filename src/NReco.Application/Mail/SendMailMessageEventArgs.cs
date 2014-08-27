using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Net.Mail;

namespace NReco.Application.Mail {
	
	/// <summary>
	/// Send mail request arguments.
	/// </summary>
	public class SendMailMessageEventArgs : EventArgs {

		public MailMessage Message { get; set; }

		public SendMailMessageEventArgs(MailMessage msg) {
			Message = msg;
		}

	}
}
