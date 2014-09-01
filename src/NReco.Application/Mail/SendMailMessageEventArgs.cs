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

		/// <summary>
		/// Gets or sets a value indicating whether an exception should be raised if an error occurs while sending mail message
		/// </summary>
		/// <remarks>The default value is true.</remarks>
		public bool ThrowExceptionOnError { get; set; }

		public SendMailMessageEventArgs(MailMessage msg) {
			Message = msg;
			ThrowExceptionOnError = true;
		}

	}
}
