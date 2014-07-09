<%@ Control Language="c#" AutoEventWireup="false" EnableViewState="true" Inherits="System.Web.UI.UserControl"  TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<script language="c#" runat="server">
public string FileSystem { get; set; }
public string Path { get; set; }

public string GetFileDownloadUrl() {
	return String.Format("{0}file/download?filesystem={1}&path={2}", 
		AppContext.BaseUrlPath, HttpUtility.UrlEncode(FileSystem), HttpUtility.UrlEncode(Path));
}
</script>
<a class="fileLink" href="<%# GetFileDownloadUrl() %>" runat="server" visible="<%# !String.IsNullOrEmpty(Path) %>"><%# System.IO.Path.GetFileName(Path) %></a>
