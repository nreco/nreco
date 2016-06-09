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

		public ImageUtils ImageUtils { get; set; }

		public HttpFileUtils() {
			MaxBufSize = 512*1024; // 512kb
			MinBufSize = 64*1024; // 64kb
			ImageUtils = new ImageUtils();
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


		public virtual IFileObject SaveFile(IFileSystem fs, InputFileInfo inputFile ) {

			var originalFileName = Path.GetFileName(inputFile.FileName);

			var fileName = Path.Combine( inputFile.Folder, originalFileName );
				
			log.Write( LogEvent.Debug, "Saving file: {0}", fileName );

			var uploadFile = fs.ResolveFile( fileName );
			if (uploadFile.Exists()) {
				if (inputFile.Overwrite) {
					uploadFile.Delete();
				} else { 
					uploadFile = GetUniqueFile(fs, fileName);
				}
			}

			// special handling for images
			if (inputFile.ForceImageFormat!=null || inputFile.ImageMaxWidth>0 || inputFile.ImageMaxHeight>0) {
				var imgFormat = String.IsNullOrEmpty(inputFile.ForceImageFormat)?
							ImageFormat.Png : ImageUtils.ResolveImageFormat(inputFile.ForceImageFormat);

				var imgFormatExt = ImageUtils.GetImageFormatExtension(imgFormat);
				if (imgFormatExt != (Path.GetExtension(uploadFile.Name) ?? String.Empty).ToLower()) {
					uploadFile = GetUniqueFile(fs, 
						Path.Combine(inputFile.Folder, Path.GetFileNameWithoutExtension(originalFileName)+imgFormatExt ) );
				}
				uploadFile.CreateFile();
				using (var outputStream = uploadFile.Content.GetStream(FileAccess.Write)) { 
					ImageUtils.ResizeImage(
						inputFile.InputStream, outputStream,
						imgFormat,
						inputFile.ImageMaxWidth,
						inputFile.ImageMaxHeight,
						true
					);
				}
			} else {
				uploadFile.CopyFrom( inputFile.InputStream );
			}
			return uploadFile;
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
		
		public class InputFileInfo {
			public string Folder { get; set; }
			public string FileName { get; set; }
			public Stream InputStream {get; set; }

			public bool Overwrite { get; set; }

			public string ForceImageFormat {get; set;}
			public int ImageMaxWidth {get; set;}
			public int ImageMaxHeight {get; set;}

			public InputFileInfo(string fileName, Stream inputStream) {
				Folder = String.Empty;
				FileName = fileName;
				InputStream = inputStream;
				Overwrite = false;
				ForceImageFormat = null;
				ImageMaxWidth = 0;
				ImageMaxHeight = 0;

			}
		}


	}


}