using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace NReco.Web.Site {
	
	/// <summary>
	/// Extended version of standard XmlSiteMapProvider.
	/// </summary>
	public class XmlSiteMapProvider : System.Web.XmlSiteMapProvider {

		public XmlSiteMapProvider() { }

		public override SiteMapNode FindSiteMapNode(string rawUrl) {
			SiteMapNode node = base.FindSiteMapNode(rawUrl);
			if (node == null) {
				int idx;
				while (node==null && (idx=rawUrl.LastIndexOf('/'))>=0) {
					rawUrl = rawUrl.Substring(0, idx);
					node = base.FindSiteMapNode(rawUrl);
				}
			}
			return node;
		}

 

	}
}
