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
		Image img;
		try {
			img = Image.FromStream(input);
		} catch (Exception ex) {
			throw new Exception( WebManager.GetLabel("Invalid image format") );
		}
		if (img.RawFormat.Equals( ImageFormat.Bmp ) || img.RawFormat.Equals( ImageFormat.Tiff) ) {
			var newFile = fs.ResolveFile( file.Name + ".png" );
			newFile.CreateFile();
			img.Save(newFile.GetContent().OutputStream, ImageFormat.Png);
			newFile.Close();
			return newFile;
		}
		file.CreateFile();
		img.Save(file.GetContent().OutputStream, img.RawFormat);
		file.Close();
		return file;
	}

}