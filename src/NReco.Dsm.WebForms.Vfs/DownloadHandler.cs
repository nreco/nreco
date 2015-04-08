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
using NReco.Application.Web;
using NReco.Logging;
using NReco.Dsm.Vfs;
using NI.Vfs;
using NI.Ioc;

namespace NReco.Dsm.WebForms.Vfs { 

	public class DownloadHandler : IHttpHandler {
	
		static ILog log = LogManager.GetLogger(typeof(DownloadHandler));
	
		public bool IsReusable {
			get { return true; }
		}
		
		protected virtual bool IsFileCachedByClient(HttpRequest Request, DateTime contentModifiedDate) {
			string header = Request.Headers["If-Modified-Since"];
			if (header != null) {
				DateTime isModifiedSince;
				if (DateTime.TryParse(header, out isModifiedSince)) {
					return isModifiedSince >= contentModifiedDate.AddSeconds(-1);
				}
			}
			return false;		
		}


		public virtual void ProcessRequest(HttpContext context) {
			log.Write( LogEvent.Debug, "File download request: {0}", context.Request.Url.ToString() );
		
			string filesystemName = context.Request["filesystem"];
			if (String.IsNullOrEmpty(filesystemName))
				throw new Exception("Parameter missed: filesystem");
			var fs = AppContext.ComponentFactory.GetComponent<IFileSystem>(filesystemName);
			if (fs==null)
				throw new Exception(String.Format("Component does not exist: {0}", filesystemName));

			string filePath = context.Request["path"];
			if (String.IsNullOrEmpty(filePath))
				throw new Exception("Parameter missed: path");
			var file = fs.ResolveFile(filePath);

			var downloadType = context.Request["disposition"]=="attachment" ? "attachment" : "inline";
			context.Response.AddHeader("Content-Disposition", String.Format("{0}; filename=\"{1}\"",downloadType, Path.GetFileName(file.Name) ));				

			var fileExt = Path.GetExtension(file.Name).ToLower();
			var fileExtensionContentTypes = AppContext.ComponentFactory.GetComponent<IDictionary<string,string>>("fileExtensionContentTypes");
			if (fileExtensionContentTypes.ContainsKey(fileExt)) {
				context.Response.ContentType = fileExtensionContentTypes[fileExt];
			}

			var httpFileUtils = new HttpFileUtils();
			httpFileUtils.GetFile(file, new HttpContextWrapper(context) );
		}

	}


}