<%@ Application Inherits="System.Web.HttpApplication" %>

<%@ Import namespace="System.Web.Security" %>
<%@ Import namespace="System.Text.RegularExpressions" %>
<%@ Import namespace="System.Text" %>
<%@ Import namespace="System.Configuration" %>
<%@ Import namespace="NI.Winter" %>
<%@ Import namespace="NReco" %>
<%@ Import namespace="NReco.Converters" %>

<script language="C#" runat="server">

public IComponentsConfig AppComponentsConfig {
	get {
		if (Application["WinterConfig"]==null) {
			lock (Application) {
				// one more check inside monitor
				if (Application["WinterConfig"]==null) {
					Application["WinterConfig"] = ConfigurationSettings.GetConfig("components");
				}
			}
		}
		return Application["WinterConfig"] as IComponentsConfig;
	}

}

public override void Init()	{
	//throw new Exception("1");
	NReco.Converters.TypeManager.Configure();
	NReco.Web.WebManager.Configure();
}

protected void Application_BeginRequest(Object sender, EventArgs e)	{
	IProvider prv = (IProvider)TypeManager.Convert( new NI.Winter.ServiceProvider(AppComponentsConfig), typeof(IProvider) );
	NReco.Web.WebManager.ServiceProvider = prv;
}


</script>