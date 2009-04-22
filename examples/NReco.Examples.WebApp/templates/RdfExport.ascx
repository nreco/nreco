<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Web.ActionUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Import namespace="SemWeb" %>
<%@ Import namespace="NReco.Metadata" %>
<%@ Import namespace="System.IO" %>

		<script language="c#" runat="server">
protected override void OnLoad(EventArgs e) {
	base.OnLoad(e);
	var dbStore = WebManager.GetService<SelectableSource>("dbRdfStore");
	using (var rdfWr = new RdfXmlWriter( new StreamWriter(Response.OutputStream) ) ) {
		rdfWr.Namespaces.AddNamespace("http://www.nreco.qsh.eu/rdf/", "nreco");
		rdfWr.Namespaces.AddNamespace(NS.Rdf.BASE, "rdf");
		rdfWr.Namespaces.AddNamespace(NS.Rdfs.BASE, "rdfs");
		dbStore.Select(rdfWr);
	}
	Response.ContentType = "text/xml";
	Response.End();
}

</script>
