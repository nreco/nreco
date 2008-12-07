<%@ Application Inherits="System.Web.HttpApplication" %>

<%@ Import namespace="System.Web.Security" %>
<%@ Import namespace="System.Text.RegularExpressions" %>
<%@ Import namespace="System.Text" %>
<%@ Import namespace="System.Configuration" %>
<%@ Import namespace="NI.Winter" %>


<script language="C#" runat="server">

public IComponentsConfig AppComponentsConfig {
	get {
		if (Application["WinterConfig"]==null) {
			lock (Application) {
				// one more check inside monitor
				if (Application["WinterConfig"]==null) {
					Application["Config"] = ConfigurationSettings.GetConfig("components");
				}
			}
		}
		return Application["WinterConfig"] as IComponentsConfig;
	}

}

protected void Application_BeginRequest(Object sender, EventArgs e)	{
	//NReco.Web.WebManager.ServiceProvider = new NI.Winter.ServiceProvider(AppComponentsConfig);
}

</script>