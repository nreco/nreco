using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Web;
using System.Web.UI;

namespace NReco.Application.Web.Forms {

	public class ScriptLoaderHandler : IHttpHandler {

		public ScriptLoaderHandler() {
		}

		public bool IsReusable {
			get { return true; }
		}

		protected bool IsCachedByClient(HttpRequest Request, DateTime contentModifiedDate) {
			string header = Request.Headers["If-Modified-Since"];
			if (header != null) {
				DateTime isModifiedSince;
				if (DateTime.TryParse(header, out isModifiedSince)) {
					return isModifiedSince >= contentModifiedDate.AddSeconds(-1);
				}
			}
			return false;
		}

		public void ProcessRequest(HttpContext context) {
			var path = Convert.ToString( context.Request["path"] ).Replace(Path.AltDirectorySeparatorChar, Path.DirectorySeparatorChar);
			// avoid 'hacks'
			if (path.IndexOf(".." + Path.DirectorySeparatorChar) >= 0 || Path.GetExtension(path).ToLower() != ".js")
				throw new Exception("Invalid path: "+path);

			var fullPath = Path.Combine(HttpRuntime.AppDomainAppPath, path);
			if (File.Exists(fullPath)) {
				var lastModified = File.GetLastWriteTime(fullPath);
				if (IsCachedByClient(context.Request, lastModified)) {
					context.Response.StatusCode = 304;
					context.Response.SuppressContent = true;
				} else {
                    context.Response.Cache.SetLastModified(lastModified > DateTime.Now ? DateTime.Now : lastModified);
					context.Response.ContentType = "text/javascript";
					var content = File.ReadAllText(fullPath);
					context.Response.Write(content);
					if (content.IndexOf("Sys.Application.notifyScriptLoaded()") < 0) {
						if (!content.Trim().EndsWith(";"))
							context.Response.Write(';');
						context.Response.Write("if (typeof(Sys) !== 'undefined') Sys.Application.notifyScriptLoaded();");
					}
				}
			} else {
				throw new IOException(String.Format("Script {0} does not exist.", path));
			}
		}

	}

}
