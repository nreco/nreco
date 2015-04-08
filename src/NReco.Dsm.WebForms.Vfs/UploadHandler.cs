#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2014 Vitaliy Fedorchenko
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

	public class UploadHandler : IHttpHandler {
	
		static ILog log = LogManager.GetLogger(typeof(UploadHandler));
	
		protected string InvalidFileTypeMessage = "Invalid file type";
	
		public bool IsReusable {
			get { return true; }
		}
	
		public virtual void ProcessRequest(HttpContext context) {
			try {
				ProcessRequestInternal(context);
			} catch (Exception ex) {
				log.Write(LogEvent.Error,ex);
			
				var errMsg = AppContext.GetLabel( ex.Message );
				context.Response.Write(errMsg);
				
				context.Response.StatusCode = 500;
				context.Response.StatusDescription = errMsg;
			}
		}

		protected virtual IFileObject GetUniqueFile(IFileSystem fs, string fileName) {
			int fileNum = 0;
			IFileObject uniqueFile = null;
			do {
				fileNum++;
				var extIdx = fileName.LastIndexOf('.');
				var newFileName = extIdx>=0 ? String.Format("{0}{1}{2}", fileName.Substring(0,extIdx), fileNum, fileName.Substring(extIdx) ) : fileName+fileNum.ToString();
				uniqueFile = fs.ResolveFile(newFileName);
			} while ( uniqueFile.Exists() && fileNum<100 );
			if (uniqueFile.Exists()) {
				var extIdx = fileName.LastIndexOf('.');
				var uniqueSuffix = Guid.NewGuid().ToString();
				uniqueFile = fs.ResolveFile(
					extIdx>=0 ?  fileName.Substring(0,extIdx)+uniqueSuffix+fileName.Substring(extIdx) : fileName+uniqueSuffix );
			}
			return uniqueFile;
		}
	
		protected virtual void ProcessRequestInternal(HttpContext context) {
		
			log.Write( LogEvent.Debug, "File upload request: {0}", context.Request.Url.ToString() );
		
			string filesystemName = context.Request["filesystem"];
			if (String.IsNullOrEmpty(filesystemName))
				throw new Exception("Parameter missed: filesystem");
			var fs = AppContext.ComponentFactory.GetComponent<IFileSystem>(filesystemName);
			if (fs==null)
				throw new Exception(String.Format("Component does not exist: {0}", filesystemName));

			string folder = context.Request["folder"];
			if (String.IsNullOrEmpty(folder))
				folder = String.Empty;

			var overwrite = false;
			if (context.Request["overwrite"]!=null)
				Boolean.TryParse(context.Request["overwrite"], out overwrite);

			var result = new List<IFileObject>();

			for (int i=0; i<context.Request.Files.Count; i++) {
				var file = context.Request.Files[i];
				if (String.IsNullOrEmpty(file.FileName.Trim())) { continue; }
			
				var originalFileName = Path.GetFileName(file.FileName);

				var fileName = Path.Combine( folder, originalFileName );
				
				log.Write( LogEvent.Debug, "Uploading file: {0}", fileName );
				var blockedExtensions = AppContext.ComponentFactory.GetComponent<IList<string>>("blockedUploadFileExtensions");
				if (blockedExtensions.Contains( Path.GetExtension(fileName).ToLower())) {
					throw new Exception(AppContext.GetLabel(InvalidFileTypeMessage));
				}
			
				var uploadFile = fs.ResolveFile( fileName );
				if (uploadFile.Exists() && !overwrite) {
					uploadFile = GetUniqueFile(fs, fileName);
				}
				
				// special handling for images
				if (context.Request["imageformat"]!=null || context.Request["image_max_width"]!=null || context.Request["image_max_height"]!=null) {
					var imageUtils = AppContext.ComponentFactory.GetComponent<ImageUtils>("fileImageUtils");
					uploadFile = imageUtils.SaveAndResizeImage(
							file.InputStream, fs, uploadFile,
							Convert.ToInt32( context.Request["image_max_width"]??"0" ), 
							Convert.ToInt32( context.Request["image_max_height"]??"0" ),
							String.IsNullOrEmpty(context.Request["imageformat"]) ? imageUtils.ResolveImageFormat(context.Request["imageformat"]) : null
						);
				} else {
					uploadFile.CopyFrom( file.InputStream );
				}
			
				result.Add(uploadFile);
			}
		
			context.Response.Write( JsUtils.ToJsonString( 
				result.Select(f=>
					new Dictionary<string,object> {
						{"name", Path.GetFileName( f.Name ) },
						{"filepath", f.Name },
						{"size", f.Content.Size}
					}
				).ToArray() ) );


		}

	}


}