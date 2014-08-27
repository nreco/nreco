using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Transactions;
using System.Net;
using System.Net.Mail;
using NReco.Logging;

namespace NReco.Application.Mail {
	
	/// <summary>
	/// Transaction-aware mail sender that can process EventBroker send mail events.
	/// </summary>
	public class SendMail {

		static ILog log = LogManager.GetLogger(typeof(SendMail));

		protected SendMailSmtpConfiguration SmtpConfig { get; set; }

		public SendMail(SendMailSmtpConfiguration smtpConfig) {
			SmtpConfig = smtpConfig;
		}

		public SendMail(SendMailSmtpConfiguration smtpConfig, EventBroker eventBroker) {
			SmtpConfig = smtpConfig;
			eventBroker.Subscribe<SendMailMessageEventArgs>(OnSendMailMessage);
		}

		protected void OnSendMailMessage(object sender, SendMailMessageEventArgs mailMsgArgs) {
			SendTransactional(mailMsgArgs.Message);
		}

		/// <summary>
		/// Sends the specified message to an SMTP server for delivery (immediately). 
		/// </summary>
		/// <param name="mailMsg">A MailMessage that contains the message to send.</param>
		public void Send(MailMessage mailMsg) {
			log.Write(LogEvent.Info, "Sending mail to={0} subject={1}", mailMsg.To, mailMsg.Subject);

			var smtp = new SmtpClient(SmtpConfig.Server, SmtpConfig.Port);
			if (!String.IsNullOrEmpty(SmtpConfig.User) && !String.IsNullOrEmpty(SmtpConfig.Password)) {
				smtp.Credentials = new NetworkCredential(SmtpConfig.User, SmtpConfig.Password);
				smtp.EnableSsl = SmtpConfig.Ssl;
			}

			smtp.Send(mailMsg);

			log.Write(LogEvent.Info, "SUCCESS: mail sent to={0} subject={1}", mailMsg.To, mailMsg.Subject);
		}

		/// <summary>
		/// Sends the specified message to an SMTP server for delivery on transaction commit (if present). 
		/// </summary>
		/// <param name="mailMsg">A MailMessage that contains the message to send.</param>
		public void SendTransactional(MailMessage mailMsg) {
			var currentTx = Transaction.Current;
			if (currentTx != null) 	{
				var sendMailRM = new SendMailRM(this, mailMsg);
				currentTx.EnlistVolatile(sendMailRM, EnlistmentOptions.None);
			} else {
				Send(mailMsg);
			}
		}

		internal class SendMailRM : IEnlistmentNotification {

			protected SendMail SendMail;
			protected MailMessage MailMsg;

			public SendMailRM(SendMail sendMail, MailMessage mailMsg) {
				SendMail = sendMail;
				MailMsg = mailMsg;
			}

			public void Commit(Enlistment enlistment) {
				SendMail.Send(MailMsg);
			}

			public void InDoubt(Enlistment enlistment) {
			}

			public void Prepare(PreparingEnlistment preparingEnlistment) {
				preparingEnlistment.Prepared();
			}

			public void Rollback(Enlistment enlistment) {
				log.Write(LogEvent.Info, "Skipped send mail to={0} subject={1}: transaction aborted", MailMsg.To, MailMsg.Subject);
			}
		}

	}
}
