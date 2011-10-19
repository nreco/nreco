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
using System.Web;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using NReco.Web.Site;
using NI.Vfs;
using NReco.Web;

public static class ImageHelper
{
	public static ImageFormat ResolveImageFormat(string formatStr) {
		if (formatStr==null)
			return null;
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
	public static string GetImageFormatExtension(ImageFormat fmt) {
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
	

	public static IFileObject SaveCompressedImage(Stream input, IFileSystem fs, IFileObject file) {
		return SaveAndResizeImage(input, fs, file, 0, 0);
	}

	public static IFileObject SaveAndResizeImage(Stream input, IFileSystem fs, IFileObject file, int maxWidth, int maxHeight ) {
		return SaveAndResizeImage(input,fs,file,maxWidth,maxHeight,null);
	}
	
	public static IFileObject SaveAndResizeImage(Stream input, IFileSystem fs, IFileObject file, int maxWidth, int maxHeight, ImageFormat saveAsFormat ) {
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
			throw new Exception( WebManager.GetLabel("Invalid image format") );
		}
		if (img.Size.Width==0 || img.Size.Height==0)
			throw new Exception( WebManager.GetLabel("Invalid image size") );
		
		var sizeIsWidthOk = (maxWidth<=0 || img.Size.Width<=maxWidth);
		var sizeIsHeightOk = (maxHeight<=0 || img.Size.Height<=maxHeight);
		var sizeIsOk = sizeIsWidthOk && sizeIsHeightOk;
		var formatIsOk = (saveAsFormat==null && !img.RawFormat.Equals(ImageFormat.Bmp) && !img.RawFormat.Equals(ImageFormat.Tiff) ) || img.RawFormat.Equals(saveAsFormat);
		if (!formatIsOk || !sizeIsOk ) {
			var newFmtExtension = saveAsFormat==null ? ".png" : GetImageFormatExtension(saveAsFormat);
			
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
				resizedBitmap.Save(newFile.GetContent().OutputStream, saveAsFormat ?? ImageFormat.Png);
			} else {
				img.Save(newFile.GetContent().OutputStream, saveAsFormat ?? ImageFormat.Png );
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
	
	public static void CropImage(Stream input, Stream output, float relStartX, float relStartY, float relEndX, float relEndY, ImageFormat saveAsFormat ) {
		Image img = null;
		try {
			img = Image.FromStream(input);
		} catch (Exception ex) {
			throw new Exception( WebManager.GetLabel("Invalid image format") );
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