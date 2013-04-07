#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2011 Vitaliy Fedorchenko
 * Distributed under the LGPL licence
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#endregion

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.Routing;
using System.Text;
using System.Linq;
using System.Drawing;
using System.Drawing.Imaging;

using NReco;
using NReco.Web;
using NReco.Web.Site;
using NReco.Logging;
using NI.Vfs;

public class FileTreeAjaxHandler : RouteHttpHandler {
	
	static ILog log = LogManager.GetLogger(typeof(FileTreeAjaxHandler));
	
	public static string InvalidFileTypeMessage = "Invalid file type";
	
	public override bool IsReusable {
		get { return false; }
	}

	protected HttpContext Context;
	
	protected object GetParam(string name) {
		if (RouteContext.ContainsKey(name)) {
			// special logic for "file" param
			if (name=="file" && !String.IsNullOrEmpty(Context.Request.Url.Query) ) {
				var result = HttpUtility.UrlDecode( Context.Request.Url.Query.Substring(1) ); // exclude leading '?' char
				if (result.IndexOf("&thumbnail") > 0) {
					result = result.Substring(0, result.IndexOf("&thumbnail"));
				}
				return result;
			}
			return RouteContext[name];
		}
		return Context.Request[name];
	}
	
	public override void ProcessRequest(HttpContext context) {
		try {
			ProcessRequestInternal(context);
		} catch (Exception ex) {
			log.Write(LogEvent.Error,ex);
			
			var errMsg = (context.Request["errorprefix"]??String.Empty)+WebManager.GetLabel( ex.Message );
			context.Response.Write(errMsg);
			
			context.Response.StatusCode = 500;
			context.Response.StatusDescription = errMsg;
		}
	}
	
	protected void ProcessRequestInternal(HttpContext context) {
		Context = context;
		
		var Request = context.Request;
		var Response = context.Response;
		log.Write( LogEvent.Info, "Processing request: {0}", Request.Url.ToString() );
		
		string filesystem = GetParam("filesystem") as string;
		if (String.IsNullOrEmpty(filesystem))
			throw new Exception("Parameter missed: filesystem");
		var fs = WebManager.GetService<IFileSystem>(filesystem);
		
		string action = GetParam("action") as string;
		if ( action!=null && action!="" && action!="upload" && action!="download" && !Request.IsAuthenticated)
			throw new System.Security.SecurityException("Action '"+action+"' is available only for authenticated users");

		
		if (action=="upload") {
			HandleUpload(Request,Response,filesystem);			
			return;
		}
		
		string showDir = HttpUtility.UrlDecode( Request["dir"] ?? String.Empty ).Replace("\\","/");
		if (showDir.EndsWith("/"))
			showDir = showDir.Substring(0, showDir.Length-1);
		if (showDir.StartsWith("/"))
			showDir = showDir.Substring(1);
		
		var fileVfsPath = GetParam("file") as string;
		if (!AssertHelper.IsFuzzyEmpty(fileVfsPath)) {
			var fileObj = fs.ResolveFile(fileVfsPath);
			if (!AssertHelper.IsFuzzyEmpty(Request["thumbnail"])) {
				var requestThumbnailParts = Request["thumbnail"].Split(new char[] { ',' });
				fileObj = GetThumbnail(fileObj, fs, requestThumbnailParts[0], requestThumbnailParts[1]);
			}
			if (action=="delete") {
				fileObj.Delete();
				return;
			} else if (action=="rename") {
				var newFile = fs.ResolveFile( Path.Combine( Path.GetDirectoryName( fileObj.Name ), Request["newname"] ) );
				fileObj.MoveTo(newFile);
				var renSb = new StringBuilder();
				RenderFile(renSb, fs.ResolveFile( newFile.Name ), false, true, Request["extraInfo"]=="1", filesystem);
				Response.Write(renSb.ToString());
				return;
			} else if (action=="move") {
				var destFolder = Request["dest"];
				var newFile = fs.ResolveFile( destFolder=="/" || destFolder=="" ? Path.GetFileName( fileObj.Name ) : Path.Combine( destFolder, Path.GetFileName( fileObj.Name ) ) );
				fileObj.MoveTo(newFile);
				return;
			}
			
			if (fileObj.Exists()) {
				// lets handle 'If-Modified-Since' header to avoid excessive http traffic
			   if (IsFileCachedByClient(Request, fileObj.GetContent().LastModifiedTime)) {
				  Response.StatusCode = 304;
				  Response.SuppressContent = true;
				  log.Write(LogEvent.Debug,"Not modified, returned HTTP/304");
			   } else {			
					Stream inputStream;
					using (inputStream = fileObj.GetContent().InputStream) {
						int bytesRead;
						byte[] buf = new byte[64 * 1024];
						while ((bytesRead = inputStream.Read(buf, 0, buf.Length)) != 0) {
							Response.OutputStream.Write(buf, 0, bytesRead);
						}
					}
					var fileContentType = ResolveContentType( Path.GetExtension( fileObj.Name ) );
					if (fileContentType!=null)
						Response.ContentType = fileContentType;
					Response.Cache.SetLastModified(fileObj.GetContent().LastModifiedTime );
					Response.AddHeader("Content-Disposition", String.Format("{0}; filename=\"{1}\"", action == "download" ? "attachment" : "inline", Path.GetFileName(fileObj.Name) ));				
				}
			}
			fileObj.Close();
			
			return;
		}
		
		var dirObj = fs.ResolveFile(showDir);
		if (action=="createdir") {
			var newDirName = fs.ResolveFile( Path.Combine(dirObj.Name, Request["dirname"] ) );
			newDirName.CreateFolder();
			return;
		}
		
		var sb = new StringBuilder();
		RenderFile(sb, dirObj, true, false, Request["extraInfo"]=="1", filesystem );
		Response.Write( sb.ToString() );
	}
	
	protected IFileObject GetThumbnail(IFileObject originalFile, IFileSystem filesystem, string width, string height) {
		var resizeWidth = AssertHelper.IsFuzzyEmpty(width) ? 0 : Convert.ToInt32(width);
		var resizeHeight = AssertHelper.IsFuzzyEmpty(height) ? 0 : Convert.ToInt32(height);
		if (resizeWidth == 0 && resizeHeight == 0) {
			return originalFile;
		}
		var thumbnailFileName = String.Format("{0}-thumbnail{1}x{2}{3}", 
									Path.Combine(Path.GetDirectoryName(originalFile.Name), Path.GetFileNameWithoutExtension(originalFile.Name)), 
									resizeWidth, 
									resizeHeight, 
									Path.GetExtension(originalFile.Name)
								);
		var thumbnailFile = filesystem.ResolveFile(thumbnailFileName);
		return !thumbnailFile.Exists() 
						? ImageHelper.SaveAndResizeImage(originalFile.GetContent().InputStream, filesystem, thumbnailFile, resizeWidth, resizeHeight) 
						: thumbnailFile;
	}
	
	protected void HandleUpload(HttpRequest Request, HttpResponse Response, string filesystem) {
		var fs = WebManager.GetService<IFileSystem>(filesystem);
		var result = new List<IFileObject>();
		var resultFormat = Request["resultFormat"] ?? "text";
		for (int i=0; i<Request.Files.Count; i++) {
			var file = Request.Files[i];
			
			// skip files with empty name; such a things happends sometimes =\
			if (String.IsNullOrEmpty(file.FileName.Trim())) { continue; }
			
			var allowedExtensions = AssertHelper.IsFuzzyEmpty(Request["allowedextensions"]) ? null : JsHelper.FromJsonString<IList<string>>(HttpUtility.UrlDecode(Request["allowedextensions"]));
			var originalFileName = Path.GetFileName(file.FileName);
			var fileName = Request["dir"]!=null && Request["dir"]!="" && Request["dir"]!="/" ? Path.Combine( Request["dir"], originalFileName ) : originalFileName;
			log.Write( LogEvent.Info, "Uploading - file name: {0}", fileName );
			if ((allowedExtensions != null && allowedExtensions.IndexOf(Path.GetExtension(fileName).ToLower()) < 0) || Array.IndexOf(blockedExtensions, Path.GetExtension(fileName).ToLower() )>=0) {
				throw new Exception(WebManager.GetLabel(FileTreeAjaxHandler.InvalidFileTypeMessage));
			}
			
			var uploadFile = fs.ResolveFile( fileName );
			var uploadPNGFile = fs.ResolveFile( fileName+".png" ); // additional checking of resized images if file names are similar
			if ((uploadFile.Exists() || uploadPNGFile.Exists()) && Request["overwrite"]!=null && !Convert.ToBoolean(Request["overwrite"])) {
				int fileNum = 0;
				do {
					fileNum++;
					var extIdx = fileName.LastIndexOf('.');
					var newFileName = extIdx>=0 ? String.Format("{0}{1}{2}", fileName.Substring(0,extIdx), fileNum, fileName.Substring(extIdx) ) : fileName+fileNum.ToString();
					uploadFile = fs.ResolveFile(newFileName);
				} while ( uploadFile.Exists() && fileNum<100 );
				if (uploadFile.Exists()) {
					var extIdx = fileName.LastIndexOf('.');
					var uniqueSuffix = Guid.NewGuid().ToString();
					uploadFile = fs.ResolveFile(
						extIdx>=0 ?  fileName.Substring(0,extIdx)+uniqueSuffix+fileName.Substring(extIdx) : fileName+uniqueSuffix ); // 99.(9)% new file!
				}
				fileName = uploadFile.Name;
			}
			// special handling for images
			if (Request["image"]=="compressed" || Request["imageformat"]!=null || Request["image_max_width"]!=null || Request["image_max_height"]!=null) {
				uploadFile = ImageHelper.SaveAndResizeImage(
						file.InputStream, fs, uploadFile,
						Convert.ToInt32( Request["image_max_width"]??"0" ), 
						Convert.ToInt32( Request["image_max_height"]??"0" ),
						Request["imageformat"]!=null ? ImageHelper.ResolveImageFormat(Request["imageformat"]) : null
					);
			} else {
				uploadFile.CopyFrom( file.InputStream );
			}
			
			result.Add(uploadFile);
		}
		
		switch (resultFormat) {
			case "text":
				Response.Write( String.Join("\n", result.Select(f=>f.Name).ToArray() ) );
				break;
			case "json":
				Response.Write( JsHelper.ToJsonString( 
					result.Select(f=>
						new Dictionary<string,object> {
							{"name", Path.GetFileName( f.Name ) },
							{"filepath", f.Name },
							{"size", f.GetContent().Size},
							{"url", VfsHelper.GetFileUrl(filesystem, f.Name) }
						}
					).ToArray() ) );
				break;
		}
		
	}
	
	
	protected bool IsFileCachedByClient(HttpRequest Request, DateTime contentModifiedDate) {
	   string header = Request.Headers["If-Modified-Since"];
	   if (header != null) {
		  DateTime isModifiedSince;
		  if (DateTime.TryParse(header, out isModifiedSince)) {
			 return isModifiedSince >= contentModifiedDate.AddSeconds(-1);
		  }
	   }
	   return false;		
	}
	
	protected string RenderFileInfo(IFileObject file) {
		var content = file.GetContent();
		string size = VfsHelper.FormatFileSize(content.Size);
		return String.Format("<div class=\"fileinfo date\">{1:d}</div><div class=\"fileinfo size\">{0}</div>",
					size, content.LastModifiedTime);
	}
	
	protected void RenderFile(StringBuilder sb, IFileObject file, bool renderChildren, bool renderFile, bool extraInfo, string filesystemName) {
		var filePath = file.Name.Replace("\\", "/");
		var fileName = Path.GetFileName(file.Name);
		if (fileName==String.Empty)
			fileName = "Root";
		switch (file.Type) {
			case FileType.File:
				var ext = Path.GetExtension(file.Name);
				if (ext!=null && ext.Length>1)
					ext = ext.Substring(1);
				if (renderFile)
					sb.AppendFormat("<li class=\"file ext_{0} {4}\">{3}<a class='file' href=\"javascript:void(0)\" rel=\"{1}\" filename=\"{2}\" fileurl=\"{5}\"><span class='name'>{2}</span></a></li>", 
						ext, filePath, fileName,
						extraInfo ? RenderFileInfo(file) : "", 
						extraInfo ? "fileInfo" : "",
						HttpUtility.HtmlAttributeEncode( VfsHelper.GetFileFullUrl(filesystemName,filePath) ) );	
				break;
			case FileType.Folder:
				if (renderFile)
					sb.AppendFormat("<li class=\"directory {2}\"><a class='directory' href=\"#\" rel=\"{0}/\" filename=\"{1}\"><span class='name'>{1}</span></a>", 
						filePath, fileName, (filePath!="" ? (renderChildren ? "expanded" : "collapsed") : "" )  );
				if (renderChildren) {
					sb.Append("<ul class=\"jqueryFileTree\" style=\"display: none;\">");
					var folders = new List<IFileObject>();
					var files = new List<IFileObject>();
					var folderFiles = file.GetChildren();
					Array.Sort(folderFiles, delegate(IFileObject x,IFileObject y) { return x.Name.CompareTo(y.Name); } );
					foreach (var f in folderFiles)
						if (f.Type==FileType.Folder)
							folders.Add( f );
						else
							files.Add(f );
					foreach (var f in folders)
						RenderFile(sb, f, false, true, extraInfo, filesystemName);
					foreach (var f in files)
						RenderFile(sb, f, false, true, extraInfo, filesystemName);
					sb.Append("</ul>");
				}
				sb.Append("</li>");
				break;
		}
	}
	
	public static string ResolveContentType(string extension) {
		var fileExt = extension.ToLower();
		if (knownContentTypes.ContainsKey(fileExt))
			return knownContentTypes[fileExt];
		return null;
	}
	
	static string[] blockedExtensions = new [] { ".exe", ".dll", ".com", ".bat" };
	
	static IDictionary<string,string> knownContentTypes = new Dictionary<string,string> {
	{".swf","application/x-shockwave-flash"},
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
	{".docx","application/vnd.openxmlformats-officedocument.wordprocessingml.document"},
	{".dot","application/msword"},
	{".dotx","application/vnd.openxmlformats-officedocument.wordprocessingml.template"},
	{".dvi","application/x-dvi"},
	{".dxr","application/x-director"},
	{".eps","application/postscript"},
	{".etx","text/x-setext"},
	{".evy","application/envoy"},
	{".exe","application/octet-stream"},
	{".fif","application/fractals"},
	{".flr","x-world/x-vrml"},
	{".flv","video/x-flv"},
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
	{".mp4","video/mp4"},
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
	{".ppsx","application/vnd.openxmlformats-officedocument.presentationml.slideshow"},
	{".ppt","application/vnd.ms-powerpoint"},
	{".pptx","application/vnd.openxmlformats-officedocument.presentationml.presentation"},
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
	{".wmv","video/x-ms-wmv"},
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
	{".xlsx","application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"},
	{".xlt","application/vnd.ms-excel"},
	{".xltx","application/vnd.openxmlformats-officedocument.spreadsheetml.template"},
	{".xlw","application/vnd.ms-excel"},
	{".xof","x-world/x-vrml"},
	{".xpm","image/x-xpixmap"},
	{".xwd","image/x-xwindowdump"},
	{".z","application/x-compress"},
	{".zip","application/zip"}
	 };
	

}

public static class VfsHelper {
	
	public static string FormatFileSize(long size) {
		return (size<1024 ?
						String.Format("{0}b", size) :
						(size<(1024*1024) ?
							String.Format("{0:0.#}kb", size/(double)1024) :
								String.Format("{0:0.#}mb", size/(double)(1024*1024) ) ) );
	}	
	
	private static string GetFileUrlPrefix(string fileSystemName, bool isDownload) {
		var routeName = isDownload ? "VfsFileDownloadUrl" : "VfsFileUrl";
		if (RouteTable.Routes[routeName]!=null) {
			var vpd = RouteTable.Routes.GetVirtualPath(null, routeName, new RouteValueDictionary { { "filesystem", fileSystemName } });
			if (vpd==null)
				throw new Exception("Invalid configuration for route "+routeName);
			var virtualPath = vpd.VirtualPath;
			var basePath = VirtualPathUtility.AppendTrailingSlash( WebManager.BasePath );
			if (virtualPath.StartsWith(basePath))
				virtualPath = virtualPath.Substring(basePath.Length);
			int paramStart = virtualPath.IndexOf('?');
			return (paramStart >= 0 ? virtualPath.Substring(0, paramStart) : virtualPath)+"?";
		}
		return isDownload ? 
				String.Format("FileTreeAjaxHandler.axd?filesystem={0}&action=download&file=", fileSystemName ) :
				String.Format("FileTreeAjaxHandler.axd?filesystem={0}&file=", fileSystemName );
	}
	
	private static string GetFileResizeUrlPart(string url, int? width, int? height) {
		var separator = url.IndexOf("&") >= 0 || url.IndexOf("?") >= 0 ? "&" : "?";
		return width.HasValue || height.HasValue ? String.Format("{0}thumbnail={1},{2}", separator, width.GetValueOrDefault(0), height.GetValueOrDefault(0)) : "";
	}
	
	public static string GetFileUrl(string fileSystemName, string vfsName) {
		return GetFileUrlPrefix(fileSystemName,false)+HttpUtility.UrlEncode(vfsName);
	}

	public static string GetFileFullUrl(string fileSystemName, string vfsName) {
		return VirtualPathUtility.AppendTrailingSlash( WebManager.BaseUrl )+GetFileUrlPrefix(fileSystemName,false)+HttpUtility.UrlEncode(vfsName);
	}
	
	public static string GetFileThumbnailUrl(string fileSystemName, string vfsName, int? width, int? height) {
		var result = GetFileUrlPrefix(fileSystemName,false) + HttpUtility.UrlEncode(vfsName);
		result += GetFileResizeUrlPart(result, width, height);
		return result;
	}
	
	public static string GetFileThumbnailFullUrl(string fileSystemName, string vfsName, int? width, int? height) {
		return VirtualPathUtility.AppendTrailingSlash( WebManager.BaseUrl )+GetFileThumbnailUrl(fileSystemName, vfsName, width, height);
	}
	
	public static string GetFileDownloadUrl(string fileSystemName, string vfsName) {
		return GetFileUrlPrefix(fileSystemName,true)+HttpUtility.UrlEncode(vfsName);
	}
	
	public static string GetFileDownloadFullUrl(string fileSystemName, string vfsName) {
		return VirtualPathUtility.AppendTrailingSlash( WebManager.BaseUrl )+GetFileUrlPrefix(fileSystemName,true)+HttpUtility.UrlEncode(vfsName);
	}
	
	
	public static bool IsImageFile(string vfsName) {
		var ext = Path.GetExtension(vfsName); 
		if (!String.IsNullOrEmpty(ext)) {
			var contentType = FileTreeAjaxHandler.ResolveContentType(ext);
			if (contentType!=null && contentType.StartsWith("image/"))
				return true;
		}		
		return false;
	}
}

public static class FileTreeAjaxHandlerControlExtensions {
	// deprecated; use GetFileUrl instead
	public static string GetVfsFileUrl(this Control ctrl, string fileSystemName, string vfsName) {
		return VfsHelper.GetFileUrl(fileSystemName,vfsName);
	}
	
	public static string GetFileFullUrl(this Control ctrl, string fileSystemName, string vfsName) {
		return VfsHelper.GetFileFullUrl(fileSystemName,vfsName);
	}	
	
	public static string GetFileUrl(this Control ctrl, string fileSystemName, string vfsName) {
		return FileTreeAjaxHandlerControlExtensions.GetVfsFileUrl(ctrl, fileSystemName, vfsName);
	}
	
	public static string GetFileDownloadUrl(this Control ctrl, string fileSystemName, string vfsName) {
		return VfsHelper.GetFileDownloadUrl(fileSystemName,vfsName);
	}
	
	public static bool IsImageFile(this Control ctrl, string vfsName) {
		return VfsHelper.IsImageFile(vfsName);
	}
}