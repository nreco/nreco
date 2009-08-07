<%@ Page Language="C#" MasterPageFile="~/Site.Master" Inherits="NReco.Web.Site.RoutePage" %>

<script runat="server" language="c#">
</script>

<asp:Content ContentPlaceHolderID="main" runat="server">

<div style="padding: 5px;">
<h1>Welcome to NReco Web Application Sample!</h1>
<p >
This sample illustrates how application prototype can be defined using NReco DSMs in 10 minutes (ok, may be 15 :-):
<ol>
	<li><a href="http://code.google.com/p/nreco/source/browse/trunk/examples/NReco.Examples.WebApp/config/dsm/entities.xml">Define entity model</a>
	<li><a href="http://code.google.com/p/nreco/source/browse/trunk/examples/NReco.Examples.WebApp/config/dsm/db.xml">Define data layer with triggers</a>
	<li><a href="http://code.google.com/p/nreco/source/browse/trunk/examples/NReco.Examples.WebApp/config/dsm/layouts.xml">Define UI layouts</a>
	<li><a href="http://code.google.com/p/nreco/source/browse/trunk/examples/NReco.Examples.WebApp/config/dsm/lookups.xml">Define supporting services</a>
	<li>Enjoy your fully functional prototype ("Generated" menu subtree)</a>
</ol>
With additional 5 mins application becomes semantic-web ready:
<ol>
	<li><a href="http://code.google.com/p/nreco/source/browse/trunk/examples/NReco.Examples.WebApp/config/dsm/dbRdf.xml">Define RDB-to-RDF mapping model</a>
	<li><a href="rdfexport.aspx">Export your data in RDF/XML format</a>
	<li><a href="rdfbrowser.aspx?resource=<%=HttpUtility.UrlEncode("http://www.nreco.qsh.eu/rdf/page") %>">Try embedded RDF Browser!</a>
</ol>

</p>
</div>

</asp:Content>
