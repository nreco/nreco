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
	
	ServiceProvider srvPrv = new ServiceProvider( (IComponentsConfig)ConfigurationSettings.GetConfig("components.webrouting") );
	IList routes = srvPrv.GetObject("routes") as IList;
	if (routes!=null)
		foreach (Route route in routes) {
			RouteTable.Routes.Add( route );
		}
	
	var siteRouteHandler = new WebFormRouteHandler<Page>( "~/pages/site.aspx" );
	RouteTable.Routes.Add( 
		new Route( "account.aspx", siteRouteHandler ) {
			DataTokens = new RouteValueDictionary() { {"main", "~/templates/AccountList.ascx"} }
		}
	);
	//RouteTable.Routes.Add( new Route( "Some.aspx/{var}", routeHandler ) );
	
}

protected void Application_BeginRequest(Object sender, EventArgs e)	{
	IProvider prv = (IProvider)ConvertManager.ChangeType( new NI.Winter.ServiceProvider(AppComponentsConfig), typeof(IProvider) );
	NReco.Web.WebManager.ServiceProvider = prv;
}


</script>