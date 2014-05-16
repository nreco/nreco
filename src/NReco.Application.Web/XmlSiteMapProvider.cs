#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008,2009 Vitaliy Fedorchenko
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
using System.Web;

namespace NReco.Web.Site {
	
	/// <summary>
	/// Extended version of standard XmlSiteMapProvider used in NReco applications.
	/// </summary>
	public class XmlSiteMapProvider : System.Web.XmlSiteMapProvider {

		public XmlSiteMapProvider() { }

		public override SiteMapNode FindSiteMapNode(string rawUrl) {
			SiteMapNode node = base.FindSiteMapNode(rawUrl);
			if (node == null) {
				int idx;
				while (node==null && (idx=rawUrl.LastIndexOfAny( new []{'/','?'} ))>=0) {
					rawUrl = rawUrl.Substring(0, idx);
					node = base.FindSiteMapNode(rawUrl);
				}
			}
			return node;
		}

 

	}
}
