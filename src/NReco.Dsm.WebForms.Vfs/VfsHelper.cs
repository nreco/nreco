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
using System.Web;
using System.Web.UI;
using System.Web.Routing;
using System.Text;
using System.IO;
using System.Linq;
using System.Drawing;
using System.Drawing.Imaging;

using NReco;
using NReco.Logging;
using NI.Vfs;

namespace NReco.Dsm.WebForms.Vfs {

	public static class VfsHelper {
	
		public static string FormatFileSize(long size) {
			return (size<1024 ?
							String.Format("{0}b", size) :
							(size<(1024*1024) ?
								String.Format("{0:0.#}kb", size/(double)1024) :
									String.Format("{0:0.#}mb", size/(double)(1024*1024) ) ) );
		}

		public static string ResolveWebAppLocalPath(string path) {
			return path.Replace("~/", VirtualPathUtility.AppendTrailingSlash(HttpRuntime.AppDomainAppPath) );
		}
	
		public static ImageFormat ResolveImageFormat(string formatStr) {
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
	}

}