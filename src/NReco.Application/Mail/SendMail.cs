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
			SendTransactional(mailMsgArgs.Message, mailMsgArgs.ThrowExceptionOnError);
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
		/// <param name="throwExceptionOnError">Determines whether an exception should be raised if an error occurs while sending mail message</param>
		public void SendTransactional(MailMessage mailMsg, bool throwExceptionOnError) {
			var currentTx = Transaction.Current;
			var sendMailRM = new SendMailRM(this, mailMsg, throwExceptionOnError);
			if (currentTx != null) 	{
				currentTx.EnlistVolatile(sendMailRM, EnlistmentOptions.None);
			} else {
				sendMailRM.Execute();
			}
		}

		internal class SendMailRM : IEnlistmentNotification {
			protected SendMail SendMail;
			protected MailMessage MailMsg;
			protected bool ThrowExceptionOnError;

			public SendMailRM(SendMail sendMail, MailMessage mailMsg, bool throwOnError) {
				SendMail = sendMail;
				MailMsg = mailMsg;
				ThrowExceptionOnError = throwOnError;
			}

			public void Commit(Enlistment enlistment) {
			}

			public void InDoubt(Enlistment enlistment) {
			}

			public void Execute() {
				try { 
					SendMail.Send(MailMsg);
				} catch (Exception ex) {
					if (ThrowExceptionOnError) {
						throw new Exception(
							String.Format("Error sending mail to={0} subject={1}: {2}", MailMsg.To, MailMsg.Subject, ex.Message),
							ex
						);
					} else {
						log.Write(LogEvent.Error, "Error sending mail to={0} subject={1}: {2}", MailMsg.To, MailMsg.Subject, ex);
					}
				}
			}

			public void Prepare(PreparingEnlistment preparingEnlistment) {
				Execute();
				preparingEnlistment.Prepared();
			}

			public void Rollback(Enlistment enlistment) {
				log.Write(LogEvent.Info, "Skipped send mail to={0} subject={1}: transaction aborted", MailMsg.To, MailMsg.Subject);
			}
		}

	}
}
