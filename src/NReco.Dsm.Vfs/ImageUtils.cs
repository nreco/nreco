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
using NI.Vfs;

using NReco.Application;

namespace NReco.Dsm.Vfs {

	public class ImageUtils
	{
		public long SaveJpegQuality { get; set; }

		public ImageUtils() {
			SaveJpegQuality = 90L;
		}

		public virtual ImageFormat ResolveImageFormat(string formatStr) {
			if (formatStr==null)
				return null;
			if (formatStr.StartsWith("."))
				formatStr = formatStr.Substring(1);
		
			var formatStrLower = formatStr.ToLower();
			if (formatStrLower=="icon" || formatStrLower=="ico")
				return ImageFormat.Icon;
			if (formatStrLower=="png")
				return ImageFormat.Png;
			if (formatStrLower=="jpg" || formatStrLower=="jpeg")
				return ImageFormat.Jpeg;
			if (formatStrLower=="gif")
				return ImageFormat.Gif;
			if (formatStrLower=="bmp")
				return ImageFormat.Bmp;
			if (formatStrLower=="tiff")
				return ImageFormat.Tiff;
			return null;
		}

		public virtual string GetImageFormatExtension(ImageFormat fmt) {
			if (ImageFormat.Icon.Equals(fmt))
				return ".ico";
			if (ImageFormat.Tiff.Equals(fmt))
				return ".tiff";
			if (ImageFormat.Bmp.Equals(fmt))
				return ".bmp";
			if (ImageFormat.Gif.Equals(fmt))
				return ".gif";
			if (ImageFormat.Jpeg.Equals(fmt))
				return ".jpg";
			if (ImageFormat.Png.Equals(fmt))
				return ".png";
			return null;
		}

		/// <summary>
		/// Proportionallly resizes (preserves aspect ratio) an image for matching specified constraints (format, max width, max height)
		/// </summary>
		/// <param name="input">input stream with original image</param>
		/// <param name="output">output stream for resized image</param>
		/// <param name="saveAsFormat">format of resized image</param>
		/// <param name="maxWidth">max width (in pixels) constraint (0 = no width constraint)</param>
		/// <param name="maxHeight">max height (in pixels) constraint (0 = no height constraint)</param>
		/// <param name="saveIfNotResized">flag that forces image save to output stream even if resize is not needed</param>
		/// <returns>true if image was actually resized</returns>
		public virtual bool ResizeImage(Stream input, Stream output, ImageFormat saveAsFormat, int maxWidth, int maxHeight, bool saveIfNotResized) {
			Image img;
			try {
				img = Image.FromStream(input);
			} catch (Exception ex) {
				throw new Exception("Invalid image format");
			}
			if (img.Size.Width==0 || img.Size.Height==0)
				throw new Exception("Invalid image size");
		
			var sizeIsWidthOk = (maxWidth<=0 || img.Size.Width<=maxWidth);
			var sizeIsHeightOk = (maxHeight<=0 || img.Size.Height<=maxHeight);
			var sizeIsOk = sizeIsWidthOk && sizeIsHeightOk;
		
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
				
				SaveImage(resizedBitmap, output, saveAsFormat);
				return true;
			} else {
				if (saveIfNotResized)
					SaveImage(img, output, saveAsFormat );
				return false;
			}
		}
	
		protected virtual void SaveImage(Image img, Stream outputStream, ImageFormat fmt) {
			if (fmt==ImageFormat.Jpeg) {
				// for jpeg, lets set 90% quality explicitely
				ImageCodecInfo[] codecs = ImageCodecInfo.GetImageDecoders();
				var jpegCodec = codecs.Where( c=> c.FormatID == ImageFormat.Jpeg.Guid ).FirstOrDefault();
				if (jpegCodec!=null) {
					var jpegEncoderParameters = new EncoderParameters(1);
					jpegEncoderParameters.Param[0] = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, SaveJpegQuality);
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
				throw new Exception("Invalid image format", ex);
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