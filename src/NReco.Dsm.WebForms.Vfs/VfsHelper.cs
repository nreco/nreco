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
using NReco.Application.Web;
using NI.Vfs;

namespace NReco.Dsm.WebForms.Vfs {

	public static class VfsHelper {
	
		static string[] fileSizeSuffix = new [] {"b", "kb", "mb", "gb"};

		public static string FormatFileSize(long size) {
			return FormatFileSize(size, 1);
		}

		public static string FormatFileSize(long size, int precision) {
			double sizeDbl = size;
			var pFmt = new String('#', precision);
			for (int i = 0; i < fileSizeSuffix.Length; i++) {
				if (sizeDbl<1024 || i==(fileSizeSuffix.Length-1) )
					return String.Format("{0:0."+pFmt+"}{1}", sizeDbl, AppContext.GetLabel( fileSizeSuffix[i], "NReco.Dsm.WebForms.Vfs.VfsHelper.FormatFileSize") );
				sizeDbl /= 1024;
			}
			throw new InvalidOperationException();
		}

	}

}