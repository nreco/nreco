<%@ Application  Inherits="System.Web.HttpApplication" Language="C#" %>

<script language="C#" runat="server">

	protected void Application_Start(object sender, EventArgs e) {
		NReco.Logging.LogManager.Configure(new NReco.Application.Log4Net.LogFactory().GetLog );
		log4net.Config.XmlConfigurator.Configure();
	}
</script>
