using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Text;

using NReco;
using NReco.Web;
using NReco.Logging;
using NI.Vfs;

public class FileTreeAjaxHandler : IHttpHandler {
	
	static ILog log = LogManager.GetLogger(typeof(FileTreeAjaxHandler));
	
	public bool IsReusable {
		get { return true; }
	}

	public void ProcessRequest(HttpContext context) {
		var Request = context.Request;
		var Response = context.Response;
		log.Write( LogEvent.Info, "Processing request: {0}", Request.Url.ToString() );
		
		string filesystem = Request["filesystem"];
		var fs = WebManager.GetService<IFileSystem>(filesystem);
		
		if (Request["action"]=="upload") {
			for (int i=0; i<Request.Files.Count; i++) {
				var file = Request.Files[i];
				var fileName = Request["dir"]!=null && Request["dir"]!="" && Request["dir"]!="/" ? Path.Combine( Request["dir"], file.FileName ) : file.FileName;
				log.Write( LogEvent.Info, "Uploading - file name: {0}", fileName );
				var uploadFile = fs.ResolveFile( fileName );
				uploadFile.CopyFrom( file.InputStream );
			}
			Response.Write("1");
			return;
		}
		
		string showDir = HttpUtility.UrlDecode( Request["dir"] ?? String.Empty ).Replace("\\","/");
		if (showDir.EndsWith("/"))
			showDir = showDir.Substring(0, showDir.Length-1);
		if (showDir.StartsWith("/"))
			showDir = showDir.Substring(1);
		
		if (Request["file"]!=null) {
			var fileObj = fs.ResolveFile(Request["file"]);
			
			if (Request["action"]=="delete") {
				fileObj.Delete();
				return;
			} else if (Request["action"]=="rename") {
				var newFile = fs.ResolveFile( Path.Combine( Path.GetDirectoryName( fileObj.Name ), Request["newname"] ) );
				fileObj.MoveTo(newFile);
				var renSb = new StringBuilder();
				RenderFile(renSb, fs.ResolveFile( newFile.Name ), false, true, Request["extraInfo"]=="1");
				Response.Write(renSb.ToString());
				return;
			} else if (Request["action"]=="move") {
				var destFolder = Request["dest"];
				var newFile = fs.ResolveFile( destFolder=="/" || destFolder=="" ? Path.GetFileName( fileObj.Name ) : Path.Combine( destFolder, Path.GetFileName( fileObj.Name ) ) );
				fileObj.MoveTo(newFile);
				return;
			}
			
			Stream inputStream;
			using (inputStream = fileObj.GetContent().InputStream) {
				int bytesRead;
				byte[] buf = new byte[64 * 1024];
				while ((bytesRead = inputStream.Read(buf, 0, buf.Length)) != 0) {
					Response.OutputStream.Write(buf, 0, bytesRead);
				}
			}
			var fileExt = Path.GetExtension( fileObj.Name ).ToLower();
			if (knownContentTypes.ContainsKey(fileExt))
				Response.ContentType = knownContentTypes[fileExt];
			Response.End();
		}
		
		var dirObj = fs.ResolveFile(showDir);
		if (Request["action"]=="createdir") {
			var newDirName = fs.ResolveFile( Path.Combine(dirObj.Name, Request["dirname"] ) );
			newDirName.CreateFolder();
			return;
		}
		
		var sb = new StringBuilder();
		RenderFile(sb, dirObj, true, false, Request["extraInfo"]=="1" );
		Response.Write( sb.ToString() );
	}
	
	protected string RenderFileInfo(IFileObject file) {
		var content = file.GetContent();
		string size = (content.Size<1024 ?
						String.Format("{0}b", content.Size) :
						(content.Size<(1024*1024) ?
							String.Format("{0:0.#}kb", content.Size/(double)1024) :
								String.Format("{0:0.#}mb", content.Size/(double)(1024*1024) ) ) );
		return String.Format("<div class=\"fileinfo date\">{1:d}</div><div class=\"fileinfo size\">{0}</div>",
					size, content.LastModifiedTime);
	}
	
	protected void RenderFile(StringBuilder sb, IFileObject file, bool renderChildren, bool renderFile, bool extraInfo) {
		var filePath = file.Name;
		var fileName = Path.GetFileName(file.Name);
		if (fileName==String.Empty)
			fileName = "Root";
		switch (file.Type) {
			case FileType.File:
				var ext = Path.GetExtension(file.Name);
				if (ext!=null && ext.Length>1)
					ext = ext.Substring(1);
				if (renderFile)
					sb.AppendFormat("<li class=\"file ext_{0} {4}\">{3}<a class='file' href=\"javascript:void(0)\" rel=\"{1}\" filename=\"{2}\">{2}</a></li>", 
						ext, filePath, fileName,
						extraInfo ? RenderFileInfo(file) : "", 
						extraInfo ? "fileInfo" : "" );	
				break;
			case FileType.Folder:
				if (renderFile)
					sb.AppendFormat("<li class=\"directory {2}\"><a class='directory' href=\"#\" rel=\"{0}/\" filename=\"{1}\">{1}</a>", 
						filePath, fileName, (filePath!="" ? (renderChildren ? "expanded" : "collapsed") : "" )  );
				if (renderChildren) {
					sb.Append("<ul class=\"jqueryFileTree\" style=\"display: none;\">");
					var folders = new List<IFileObject>();
					var files = new List<IFileObject>();
					foreach (var f in file.GetChildren())
						if (f.Type==FileType.Folder)
							folders.Add( f );
						else
							files.Add(f );
					foreach (var f in folders)
						RenderFile(sb, f, false, true, extraInfo);
					foreach (var f in files)
						RenderFile(sb, f, false, true, extraInfo);
					sb.Append("</ul>");
				}
				sb.Append("</li>");
				break;
		}
	}
	
	
	static IDictionary<string,string> knownContentTypes = new Dictionary<string,string> {
	{".323","text/h323"},
	{".acx","application/internet-property-stream"},
	{".ai","application/postscript"},
	{".aif","audio/x-aiff"},
	{".aifc","audio/x-aiff"},
	{".aiff","audio/x-aiff"},
	{".asf","video/x-ms-asf"},
	{".asr","video/x-ms-asf"},
	{".asx","video/x-ms-asf"},
	{".au","audio/basic"},
	{".avi","video/x-msvideo"},
	{".axs","application/olescript"},
	{".bas","text/plain"},
	{".bcpio","application/x-bcpio"},
	{".bin","application/octet-stream"},
	{".bmp","image/bmp"},
	{".c","text/plain"},
	{".cat","application/vnd.ms-pkiseccat"},
	{".cdf","application/x-cdf"},
	{".cer","application/x-x509-ca-cert"},
	{".class","application/octet-stream"},
	{".clp","application/x-msclip"},
	{".cmx","image/x-cmx"},
	{".cod","image/cis-cod"},
	{".cpio","application/x-cpio"},
	{".crd","application/x-mscardfile"},
	{".crl","application/pkix-crl"},
	{".crt","application/x-x509-ca-cert"},
	{".csh","application/x-csh"},
	{".css","text/css"},
	{".dcr","application/x-director"},
	{".der","application/x-x509-ca-cert"},
	{".dir","application/x-director"},
	{".dll","application/x-msdownload"},
	{".dms","application/octet-stream"},
	{".doc","application/msword"},
	{".dot","application/msword"},
	{".dvi","application/x-dvi"},
	{".dxr","application/x-director"},
	{".eps","application/postscript"},
	{".etx","text/x-setext"},
	{".evy","application/envoy"},
	{".exe","application/octet-stream"},
	{".fif","application/fractals"},
	{".flr","x-world/x-vrml"},
	{".gif","image/gif"},
	{".gtar","application/x-gtar"},
	{".gz","application/x-gzip"},
	{".h","text/plain"},
	{".hdf","application/x-hdf"},
	{".hlp","application/winhlp"},
	{".hqx","application/mac-binhex40"},
	{".hta","application/hta"},
	{".htc","text/x-component"},
	{".htm","text/html"},
	{".html","text/html"},
	{".htt","text/webviewhtml"},
	{".ico","image/x-icon"},
	{".ief","image/ief"},
	{".iii","application/x-iphone"},
	{".ins","application/x-internet-signup"},
	{".isp","application/x-internet-signup"},
	{".jfif","image/pipeg"},
	{".jpe","image/jpeg"},
	{".jpeg","image/jpeg"},
	{".jpg","image/jpeg"},
	{".png","image/png"},
	{".js","application/x-javascript"},
	{".latex","application/x-latex"},
	{".lha","application/octet-stream"},
	{".lsf","video/x-la-asf"},
	{".lsx","video/x-la-asf"},
	{".lzh","application/octet-stream"},
	{".m13","application/x-msmediaview"},
	{".m14","application/x-msmediaview"},
	{".m3u","audio/x-mpegurl"},
	{".man","application/x-troff-man"},
	{".mdb","application/x-msaccess"},
	{".me","application/x-troff-me"},
	{".mht","message/rfc822"},
	{".mhtml","message/rfc822"},
	{".mid","audio/mid"},
	{".mny","application/x-msmoney"},
	{".mov","video/quicktime"},
	{".movie","video/x-sgi-movie"},
	{".mp2","video/mpeg"},
	{".mp3","audio/mpeg"},
	{".mpa","video/mpeg"},
	{".mpe","video/mpeg"},
	{".mpeg","video/mpeg"},
	{".mpg","video/mpeg"},
	{".mpp","application/vnd.ms-project"},
	{".mpv2","video/mpeg"},
	{".ms","application/x-troff-ms"},
	{".mvb","application/x-msmediaview"},
	{".nws","message/rfc822"},
	{".oda","application/oda"},
	{".p10","application/pkcs10"},
	{".p12","application/x-pkcs12"},
	{".p7b","application/x-pkcs7-certificates"},
	{".p7c","application/x-pkcs7-mime"},
	{".p7m","application/x-pkcs7-mime"},
	{".p7r","application/x-pkcs7-certreqresp"},
	{".p7s","application/x-pkcs7-signature"},
	{".pbm","image/x-portable-bitmap"},
	{".pdf","application/pdf"},
	{".pfx","application/x-pkcs12"},
	{".pgm","image/x-portable-graymap"},
	{".pko","application/ynd.ms-pkipko"},
	{".pma","application/x-perfmon"},
	{".pmc","application/x-perfmon"},
	{".pml","application/x-perfmon"},
	{".pmr","application/x-perfmon"},
	{".pmw","application/x-perfmon"},
	{".pnm","image/x-portable-anymap"},
	{".pot,","application/vnd.ms-powerpoint"},
	{".ppm","image/x-portable-pixmap"},
	{".pps","application/vnd.ms-powerpoint"},
	{".ppt","application/vnd.ms-powerpoint"},
	{".prf","application/pics-rules"},
	{".ps","application/postscript"},
	{".pub","application/x-mspublisher"},
	{".qt","video/quicktime"},
	{".ra","audio/x-pn-realaudio"},
	{".ram","audio/x-pn-realaudio"},
	{".ras","image/x-cmu-raster"},
	{".rgb","image/x-rgb"},
	{".rmi","audio/mid"},
	{".roff","application/x-troff"},
	{".rtf","application/rtf"},
	{".rtx","text/richtext"},
	{".scd","application/x-msschedule"},
	{".sct","text/scriptlet"},
	{".setpay","application/set-payment-initiation"},
	{".setreg","application/set-registration-initiation"},
	{".sh","application/x-sh"},
	{".shar","application/x-shar"},
	{".sit","application/x-stuffit"},
	{".snd","audio/basic"},
	{".spc","application/x-pkcs7-certificates"},
	{".spl","application/futuresplash"},
	{".src","application/x-wais-source"},
	{".sst","application/vnd.ms-pkicertstore"},
	{".stl","application/vnd.ms-pkistl"},
	{".stm","text/html"},
	{".sv4cpio","application/x-sv4cpio"},
	{".sv4crc","application/x-sv4crc"},
	{".t","application/x-troff"},
	{".tar","application/x-tar"},
	{".tcl","application/x-tcl"},
	{".tex","application/x-tex"},
	{".texi","application/x-texinfo"},
	{".texinfo","application/x-texinfo"},
	{".tgz","application/x-compressed"},
	{".tif","image/tiff"},
	{".tiff","image/tiff"},
	{".tr","application/x-troff"},
	{".trm","application/x-msterminal"},
	{".tsv","text/tab-separated-values"},
	{".txt","text/plain"},
	{".uls","text/iuls"},
	{".ustar","application/x-ustar"},
	{".vcf","text/x-vcard"},
	{".vrml","x-world/x-vrml"},
	{".wav","audio/x-wav"},
	{".wcm","application/vnd.ms-works"},
	{".wdb","application/vnd.ms-works"},
	{".wks","application/vnd.ms-works"},
	{".wmf","application/x-msmetafile"},
	{".wps","application/vnd.ms-works"},
	{".wri","application/x-mswrite"},
	{".wrl","x-world/x-vrml"},
	{".wrz","x-world/x-vrml"},
	{".xaf","x-world/x-vrml"},
	{".xbm","image/x-xbitmap"},
	{".xla","application/vnd.ms-excel"},
	{".xlc","application/vnd.ms-excel"},
	{".xlm","application/vnd.ms-excel"},
	{".xls","application/vnd.ms-excel"},
	{".xlt","application/vnd.ms-excel"},
	{".xlw","application/vnd.ms-excel"},
	{".xof","x-world/x-vrml"},
	{".xpm","image/x-xpixmap"},
	{".xwd","image/x-xwindowdump"},
	{".z","application/x-compress"},
	{".zip","application/zip"}
	 };
	

}