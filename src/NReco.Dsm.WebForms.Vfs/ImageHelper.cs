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
using System.Web;
using System.IO;
using System.Linq;
using System.Drawing;
using System.Drawing.Imaging;
using NReco.Web.Site;
using NI.Vfs;

using NReco.Application.Web;

namespace NReco.Dsm.WebForms.Vfs {

	public class ImageUtils
	{

		public IFileObject SaveCompressedImage(Stream input, IFileSystem fs, IFileObject file) {
			return SaveAndResizeImage(input, fs, file, 0, 0);
		}

		public IFileObject SaveAndResizeImage(Stream input, IFileSystem fs, IFileObject file, int maxWidth, int maxHeight ) {
			return SaveAndResizeImage(input,fs,file,maxWidth,maxHeight,null);
		}
	
		public virtual IFileObject SaveAndResizeImage(Stream input, IFileSystem fs, IFileObject file, int maxWidth, int maxHeight, ImageFormat saveAsFormat ) {
			Image img;
			MemoryStream imgSrcStream = new MemoryStream();
			byte[] buf = new byte[1024*50];
			int bufRead = 0;
			do {
				bufRead = input.Read(buf, 0, buf.Length);
				if (bufRead>0)
					imgSrcStream.Write(buf, 0, bufRead);
			} while (bufRead>0);
			imgSrcStream.Position = 0;
		
			try {
				img = Image.FromStream(imgSrcStream);
			} catch (Exception ex) {
				throw new Exception( AppContext.GetLabel("Invalid image format") );
			}
			if (img.Size.Width==0 || img.Size.Height==0)
				throw new Exception( AppContext.GetLabel("Invalid image size") );
		
			var sizeIsWidthOk = (maxWidth<=0 || img.Size.Width<=maxWidth);
			var sizeIsHeightOk = (maxHeight<=0 || img.Size.Height<=maxHeight);
			var sizeIsOk = sizeIsWidthOk && sizeIsHeightOk;
		
			var originalImgFmt = VfsHelper.ResolveImageFormat( Path.GetExtension(file.Name) ) ?? ImageFormat.Bmp;
			var formatIsOk = (saveAsFormat==null && !originalImgFmt.Equals(ImageFormat.Bmp) && !originalImgFmt.Equals(ImageFormat.Tiff) ) 
					|| originalImgFmt.Equals(saveAsFormat);
		
			if (!formatIsOk || !sizeIsOk ) {
				var saveAsFormatResolved = saveAsFormat!=null ? saveAsFormat : (originalImgFmt==ImageFormat.Jpeg?ImageFormat.Jpeg:ImageFormat.Png);
				var newFmtExtension = VfsHelper.GetImageFormatExtension(saveAsFormatResolved);
			
				var newFile = fs.ResolveFile( file.Name + (Path.GetExtension(file.Name).ToLower()==newFmtExtension ? String.Empty : newFmtExtension) );
				newFile.CreateFile();
			
				if (!sizeIsOk) {
					var newWidth = img.Size.Width;
					var newHeight = img.Size.Height;
					if (!sizeIsWidthOk) {
						newWidth = maxWidth;
						newHeight = (int) Math.Floor( ((double)img.Size.Height)*( ((double)maxWidth)/((double)img.Size.Width) )  );
						if ( maxHeight<0 || newHeight<=maxHeight )
							sizeIsHeightOk = true;
					}
					if (!sizeIsHeightOk) {
						newHeight = maxHeight;
						newWidth = (int) Math.Floor( ((double)img.Size.Width)*( ((double)maxHeight)/((double)img.Size.Height) )  );
					}
					var resizedBitmap = new Bitmap(img, newWidth, newHeight);
				
					var imageProps = img.PropertyItems;
						foreach (PropertyItem propItem in imageProps){
						resizedBitmap.SetPropertyItem(propItem);
					}				
				
					using (var newFileOutStream = newFile.Content.GetStream(FileAccess.Write)) { 
						SaveImage(resizedBitmap, newFileOutStream, saveAsFormatResolved);
					}
				
				} else {
					using (var newFileOutStream = newFile.Content.GetStream(FileAccess.Write)) { 
						SaveImage(img, newFileOutStream, saveAsFormatResolved );
					}
				}
				newFile.Close();
				return newFile;
			}
			file.CreateFile();
			imgSrcStream.Position = 0;
			file.CopyFrom( imgSrcStream );
			file.Close();
			return file;
		}
	
		protected virtual void SaveImage(Image img, Stream outputStream, ImageFormat fmt) {
			if (fmt==ImageFormat.Jpeg) {
				// for jpeg, lets set 90% quality explicitely
				ImageCodecInfo[] codecs = ImageCodecInfo.GetImageDecoders();
				var jpegCodec = codecs.Where( c=> c.FormatID == ImageFormat.Jpeg.Guid ).FirstOrDefault();
				if (jpegCodec!=null) {
					var jpegEncoderParameters = new EncoderParameters(1);
					jpegEncoderParameters.Param[0] = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, 90L);
					 img.Save(outputStream, jpegCodec, jpegEncoderParameters);
					return;
				}  
			}		
			 img.Save(outputStream, fmt);
		}
	
		public virtual void CropImage(Stream input, Stream output, float relStartX, float relStartY, float relEndX, float relEndY, ImageFormat saveAsFormat ) {
			Image img = null;
			try {
				img = Image.FromStream(input);
			} catch (Exception ex) {
				throw new Exception( AppContext.GetLabel("Invalid image format") );
			}
			var absStartX = (int) (relStartX*img.Size.Width);
			var absStartY = (int) (relStartY*img.Size.Height);
			var absEndX = (int) (relEndX*img.Size.Width);
			var absEndY = (int) (relEndY*img.Size.Height);
		
			var resizedBitmap = new Bitmap(absEndX-absStartX, absEndY-absStartY);
		
			using(Graphics g = Graphics.FromImage(resizedBitmap)) {
			   g.DrawImage(img, new Rectangle(0, 0, resizedBitmap.Width, resizedBitmap.Height), 
								new Rectangle(absStartX, absStartY, resizedBitmap.Width, resizedBitmap.Height ),                        
								GraphicsUnit.Pixel);
			}
		
			resizedBitmap.Save(output, saveAsFormat ?? ImageFormat.Png);
		}

	}

}