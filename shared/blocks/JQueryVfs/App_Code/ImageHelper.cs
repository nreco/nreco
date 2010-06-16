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
	public static IFileObject SaveCompressedImage(Stream input, IFileSystem fs, IFileObject file) {
		return SaveAndResizeImage(input, fs, file, 0, 0);
	}
	
	public static IFileObject SaveAndResizeImage(Stream input, IFileSystem fs, IFileObject file, int maxWidth, int maxHeight ) {
		Image img;
		try {
			img = Image.FromStream(input);
		} catch (Exception ex) {
			throw new Exception( WebManager.GetLabel("Invalid image format") );
		}
		if (img.Size.Width==0 || img.Size.Height==0)
			throw new Exception( WebManager.GetLabel("Invalid image size") );
		
		var sizeIsWidthOk = (maxWidth<=0 || img.Size.Width<=maxWidth);
		var sizeIsHeightOk = (maxHeight<=0 || img.Size.Height<=maxHeight);
		var sizeIsOk = sizeIsWidthOk && sizeIsHeightOk;
		if (img.RawFormat.Equals( ImageFormat.Bmp ) || img.RawFormat.Equals( ImageFormat.Tiff) || !sizeIsOk ) {
			var newFile = fs.ResolveFile( file.Name + (Path.GetExtension(file.Name).ToLower()==".png" ? String.Empty : ".png") );
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
				resizedBitmap.Save(newFile.GetContent().OutputStream, ImageFormat.Png);
			} else {
				img.Save(newFile.GetContent().OutputStream, ImageFormat.Png);
			}
			newFile.Close();
			return newFile;
		}
		file.CreateFile();
		img.Save(file.GetContent().OutputStream, img.RawFormat);
		file.Close();
		return file;		
	}

}