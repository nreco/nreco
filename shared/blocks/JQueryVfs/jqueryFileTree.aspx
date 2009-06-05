<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import namespace="NI.Vfs" %>
<%@ Import namespace="System.Collections.Generic" %>
<%@ Import namespace="System.IO" %>
<%
	
	
	string showDir = HttpUtility.UrlDecode( Request["dir"] ?? String.Empty ).Replace("\\","/");
	if (showDir.EndsWith("/"))
		showDir = showDir.Substring(0, showDir.Length-1);
	if (showDir.StartsWith("/"))
		showDir = showDir.Substring(1);
		
	string filesystem = Request["filesystem"];
	
	var fs = WebManager.GetService<IFileSystem>(filesystem);
	if (Request["file"]!=null) {
		var fileObj = fs.ResolveFile(Request["file"]);
		Stream inputStream;
		using (inputStream = fileObj.GetContent().InputStream) {
			int bytesRead;
			byte[] buf = new byte[64 * 1024];
			while ((bytesRead = inputStream.Read(buf, 0, buf.Length)) != 0) {
				Response.OutputStream.Write(buf, 0, bytesRead);
			}
		}
		Response.End();
	}
	
	var dirObj = fs.ResolveFile(showDir);
	if (!dirObj.Exists())
		throw new Exception("Folder does not exist: "+showDir);
	
	var fileObjects = dirObj.GetChildren();	
	var folders = new List<IFileObject>();
	var files = new List<IFileObject>();
	foreach (var f in fileObjects)
		if (f.Type==FileType.Folder)
			folders.Add( f );
		else
			files.Add(f );	
	
	Response.Write("<ul class=\"jqueryFileTree\" style=\"display: none;\">\n");
	foreach (var dir in folders)
		Response.Write("\t<li class=\"directory collapsed\"><a href=\"#\" rel=\"" + dir.Name + "/\">" + Path.GetFileName( dir.Name ) + "</a></li>\n");

	foreach (var file in files) {
		var ext = Path.GetExtension(file.Name);
		if (ext!=null && ext.Length>1)
			ext = ext.Substring(1);
		Response.Write("\t<li class=\"file ext_" + ext + "\"><a href=\"javascript:void(0)\" rel=\"" + file.Name + "\">" + Path.GetFileName( file.Name ) + "</a></li>\n");		
	}
	Response.Write("</ul>");
 %>