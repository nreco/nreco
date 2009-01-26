<%@ Application Inherits="System.Web.HttpApplication" %>

<%@ Import namespace="System.Web.Security" %>
<%@ Import namespace="System.Text.RegularExpressions" %>
<%@ Import namespace="System.Text" %>
<%@ Import namespace="System.Configuration" %>
<%@ Import namespace="System.Web.Routing" %>
<%@ Import namespace="NI.Winter" %>
<%@ Import namespace="NReco" %>
<%@ Import namespace="NReco.Converting" %>
<%@ Import namespace="NReco.Web.Site" %>

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
	NReco.Converting.ConvertManager.Configure();
	NReco.Web.WebManager.Configure();
	
	NReco.Winter.ServiceProvider srvPrv = new NReco.Winter.ServiceProvider(AppComponentsConfig);
	IDictionary routes = srvPrv.GetObject("webRoutes") as IDictionary;
	if (routes!=null)
		foreach (DictionaryEntry route in routes) {
			RouteTable.Routes.Add( route.Key.ToString(), (Route)route.Value );
		}
}

protected void Application_BeginRequest(Object sender, EventArgs e)	{
	IProvider prv = (IProvider)ConvertManager.ChangeType( new NReco.Winter.ServiceProvider(AppComponentsConfig), typeof(IProvider) );
	NReco.Web.WebManager.ServiceProvider = prv;
}


</script>