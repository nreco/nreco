#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2015 Vitaliy Fedorchenko
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
using System.Text;
using System.Linq;
using System.Drawing;
using System.Drawing.Imaging;

using NReco;
using NReco.Logging;
using NI.Vfs;
using NI.Ioc;

namespace NReco.Dsm.Vfs { 

	public class HttpFileUtils {
	
		static ILog log = LogManager.GetLogger(typeof(HttpFileUtils));
	
		public int MaxBufSize { get; set; }
		public int MinBufSize { get; set; }

		public HttpFileUtils() {
			MaxBufSize = 512*1024; // 512kb
			MinBufSize = 64*1024; // 64kb
		}

		protected virtual bool IsFileCachedByClient(HttpRequestBase Request, DateTime contentModifiedDate) {
			string header = Request.Headers["If-Modified-Since"];
			if (header != null) {
				DateTime isModifiedSince;
				if (DateTime.TryParse(header, out isModifiedSince)) {
					return isModifiedSince >= contentModifiedDate.AddSeconds(-1);
				}
			}
			return false;		
		}

		public virtual void GetFile(IFileObject file, HttpContextBase context) {
			if (file.Type != FileType.File) {
				throw new HttpException(404, "File not found");
			}

			// if-modified-since support
			var fileLastModified = file.Content.LastModifiedTime;
			if (IsFileCachedByClient(context.Request,fileLastModified)) {
				context.Response.StatusCode = 304;
				context.Response.SuppressContent = true;
				log.Write(LogEvent.Debug,"Not modified, returned HTTP/304");
				return;
			}
			context.Response.Cache.SetLastModified(fileLastModified);

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

			using (var fstream = file.Content.GetStream(FileAccess.Read)) {
				fstream.Seek(startPosition, SeekOrigin.Begin);
				long bytesCopied = 0;
						
				byte[] buffer = new byte[fileSize>MaxBufSize ? MaxBufSize : Math.Min( MinBufSize, fileSize )];
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

		} 
		

	}


}