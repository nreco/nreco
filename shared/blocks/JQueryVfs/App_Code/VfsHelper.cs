#region License
/*
 * NReco.Site (http://www.nrecosite.com/)
 * Copyright 2010 Vitaliy Fedorchenko
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
using System.Web;
using System.Web.UI;
using System.Web.Routing;
using System.Text;
using System.IO;
using System.Linq;
using System.Drawing;
using System.Drawing.Imaging;

using NReco;
using NReco.Web;
using NReco.Web.Site;
using NReco.Logging;
using NI.Vfs;

public static class VfsHelper {
	
	static string[] fileSizeSuffix = new [] {"b", "kb", "mb", "gb"};

	public static string FormatFileSize(long size) {
		return FormatFileSize(size, 1);
	}

	public static string FormatFileSize(long size, int precision) {
		double sizeDbl = size;
		var pFmt = new String('#', precision);
		for (int i = 0; i < fileSizeSuffix.Length; i++) {
			if (sizeDbl<1024 || i==(fileSizeSuffix.Length-1) )
				return String.Format("{0:0."+pFmt+"}{1}", sizeDbl, WebManager.GetLabel( fileSizeSuffix[i], "FormatFileSize") );
			sizeDbl /= 1024;
		}
		throw new InvalidOperationException();
	}
	
	private static string GetFileUrlPrefix(string fileSystemName, bool isDownload) {
		var routeName = isDownload ? "VfsFileDownloadUrl" : "VfsFileUrl";
		if (RouteTable.Routes[routeName]!=null) {
			var virtualPath = ControlExtensions.GetRouteUrl(routeName, new Hashtable() { { "filesystem", fileSystemName } });
			if (virtualPath==null)
				throw new Exception("Invalid configuration for route "+routeName);
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