<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Web.ActionUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Import namespace="SemWeb" %>
<%@ Import namespace="NReco" %>
<%@ Import namespace="NReco.SemWeb" %>
<%@ Import namespace="System.IO" %>

		<script language="c#" runat="server">
protected override void OnLoad(EventArgs e) {
	base.OnLoad(e);
    var luceneCompaniesFullIndexOperation = WebManager.GetService<IOperation<object>>("lucene_companies_Full_IndexOperation");
    luceneCompaniesFullIndexOperation.Execute(null);
	
}

</script>
