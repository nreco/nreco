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
					// dump RDF metadata
					var export = new NReco.Metadata.Extracting.WebAppRdfExport();
					export.Run( (IComponentsConfig)Application["WinterConfig"], @"c:\temp\_1.rdf");
				}
			}
		}
		return Application["WinterConfig"] as IComponentsConfig;
	}

}

public override void Init()	{
	NReco.Converting.ConvertManager.Configure();
	NReco.Web.WebManager.Configure();
	
	NReco.Winter.ServiceProvider srvPrv = new NReco.Winter.ServiceProvider(AppComponentsConfig);
	// configure URL routing subsystem
	IDictionary routes = srvPrv.GetObject("webRoutes") as IDictionary;
	if (routes!=null) {
		RouteTable.Routes.Clear();
		foreach (DictionaryEntry route in routes) {
			RouteTable.Routes.Add( route.Key.ToString(), (Route)route.Value );
		}
	}
	// call optional 'init' operation
	var onWebappInit = srvPrv.GetObject("on-webapp-init");
	if (onWebappInit!=null)
		ConvertManager.ChangeType<IOperation<object>>(onWebappInit).Execute(null);
}

protected void Application_BeginRequest(Object sender, EventArgs e)	{
	NReco.Web.WebManager.ServiceProvider = ConvertManager.ChangeType<IProvider<object,object>>( new NReco.Winter.ServiceProvider(AppComponentsConfig) );
}


</script>