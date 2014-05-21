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
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;

namespace NReco.Dsm.WebForms {
	
	/// <summary>
	/// Extends standard DataPager
	/// </summary>
	public class DataPager : System.Web.UI.WebControls.DataPager {
		
		HtmlTextWriterTag? _CustomTagKey = null;

		/// <summary>
		/// Get or set custom control tag that wraps whole pager HTML content
		/// </summary>
		public HtmlTextWriterTag CustomTagKey {
			get { return _CustomTagKey.HasValue ? _CustomTagKey.Value : base.TagKey; }
			set { _CustomTagKey = value; }
		}

		protected override HtmlTextWriterTag TagKey {
			get {
				return CustomTagKey;
			}
		}

	}
}
