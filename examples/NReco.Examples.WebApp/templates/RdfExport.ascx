<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Web.ActionUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Import namespace="SemWeb" %>
<%@ Import namespace="NReco.Metadata" %>
<%@ Import namespace="System.IO" %>

		<script language="c#" runat="server">
protected override void OnLoad(EventArgs e) {
	base.OnLoad(e);
	var dbStore = WebManager.GetService<SelectableSource>("dbRdfStore");
	using (var n3wr = new N3Writer( new StreamWriter(Response.OutputStream) ) ) {
		n3wr.Namespaces.AddNamespace("http://www.nreco.qsh.eu/rdf/", "nreco");
		n3wr.Namespaces.AddNamespace(NS.Rdf.BASE, "rdf");
		n3wr.Namespaces.AddNamespace(NS.Rdfs.BASE, "rdfs");
		dbStore.Select(n3wr);
	}
	Response.End();
}

</script>
