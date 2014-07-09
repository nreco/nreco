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
using NI.Vfs;
using NI.Ioc;

namespace NReco.Dsm.WebForms.Vfs { 

	public class DownloadHandler : IHttpHandler {
	
		static ILog log = LogManager.GetLogger(typeof(DownloadHandler));
	
		public bool IsReusable {
			get { return true; }
		}

		static readonly int MaxBufSize = 512*1024; // 512kb
		static readonly int MinBufSize = 64*1024; //64kb
		
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
			if (file.Type == FileType.File) {
				// if-modified-since support
				var fileLastModified = file.Content.LastModifiedTime;
				if (IsFileCachedByClient(context.Request,fileLastModified)) {
					context.Response.StatusCode = 304;
					context.Response.SuppressContent = true;
					log.Write(LogEvent.Debug,"Not modified, returned HTTP/304");
					return;
				}
				context.Response.Cache.SetLastModified(fileLastModified);

				var fileExt = Path.GetExtension(file.Name).ToLower();
				var fileExtensionContentTypes = AppContext.ComponentFactory.GetComponent<IDictionary<string,string>>("fileExtensionContentTypes");

				if (fileExtensionContentTypes.ContainsKey(fileExt))
					context.Response.ContentType = fileExtensionContentTypes[fileExt];

				var downloadType = context.Request["disposition"]=="attachment" ? "attachment" : "inline";
				context.Response.AddHeader("Content-Disposition", String.Format("{0}; filename=\"{1}\"",downloadType, Path.GetFileName(file.Name) ));				

				var fileSize = file.Content.Size;
				context.Response.AddHeader("Accept-Ranges", "bytes");
				context.Response.AddHeader("Connection", "Keep-Alive");

				long startPosition = 0;
				long returnBytes = fileSize;
				if (context.Request.Headers["Range"] != null) {
					string[] ranges = Convert.ToString(context.Request.Headers["Range"]).Replace("bytes=", String.Empty).Split(new[]{'-','='}, StringSplitOptions.None);
					if (ranges.Length==2) {
						// first N bytes
						if (String.IsNullOrEmpty(ranges[0])) {
							returnBytes = Convert.ToInt64(ranges[1]);
							startPosition = fileSize - returnBytes;
						} else if (String.IsNullOrEmpty(ranges[1])) {
							startPosition = Convert.ToInt64(ranges[0]);
							returnBytes = fileSize-(startPosition);
						} else {
							startPosition = Convert.ToInt64(ranges[0]);
							returnBytes = Convert.ToInt64(ranges[1])+1;
						}
					}
				}
				if (startPosition > 0 || returnBytes != fileSize || context.Request.Headers["Range"] != null) {
					context.Response.AddHeader("Content-Range", string.Format(" bytes {0}-{1}/{2}", startPosition, returnBytes - 1, fileSize));
					context.Response.StatusCode = 206;
				}
					
				context.Response.BufferOutput = false;
				context.Response.AddHeader("Content-Length", returnBytes.ToString());

				var outStream = context.Response.OutputStream;

				using (var fstream =file.Content.GetStream(FileAccess.Read)) {
					fstream.Seek(startPosition, SeekOrigin.Begin);
					long bytesCopied = 0;
						
					byte[] buffer = new byte[fileSize>MaxBufSize*5 ? MaxBufSize : MinBufSize];
					while (true && bytesCopied<returnBytes) {
						if (!context.Response.IsClientConnected)
							return; //client disconnected, skip downloading

						int num = fstream.Read(buffer, 0, buffer.Length);
						if ( (num+bytesCopied)> returnBytes) {
							num = (int)(returnBytes-bytesCopied);
						}

						bytesCopied+=num;

						if (num == 0)
							break;
						outStream.Write(buffer, 0, num);
					}				
				}

			} else {
				throw new HttpException(404, "File not found");
			}
		}

	}


}