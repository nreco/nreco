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
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using System.Web;
using System.Data;
using NI.Data.Dalc;

namespace NReco.Web.Site {

	/// <summary>
	/// Experimental.
	/// </summary>
	public class DalcSiteMapProvider : StaticSiteMapProvider {

		const string DalcNameAttr = "dalc";
		const string RootUrlAttr = "rootUrl";
		const string RootTitleAttr = "rootTitle";
		const string SourceNameAttr = "sourcename";

		private SiteMapNode rootNode = null;

		string RootUrl = String.Empty;
		string RootTitle = String.Empty;
		string DalcName = String.Empty;
		string SourceName = "site_menu_items";
		string IdField = "id";
		string FkField = "parent_item_id";
		string TitleField = "title";
		string UrlField = "url";

		public DalcSiteMapProvider() {

		}

		public override SiteMapNode RootNode {
			get { return BuildSiteMap(); }
		}

		public override void Initialize(string name, NameValueCollection attributes) {

			if (attributes[DalcNameAttr] != null)
				DalcName = attributes[DalcNameAttr];
			if (attributes[RootUrlAttr] != null)
				RootUrl = attributes[RootUrlAttr];
			if (attributes[RootTitleAttr] != null)
				RootTitle = attributes[RootTitleAttr];
			if (attributes[SourceNameAttr] != null)
				SourceName = attributes[SourceNameAttr];

			base.Initialize(name, attributes);
		}

		public override SiteMapNode BuildSiteMap() {
			lock(this) {
				Clear();

				var dalc = WebManager.GetService<IDalc>(DalcName);
				var ds = new DataSet();
				dalc.Load(ds, new Query(SourceName));
				rootNode = new SiteMapNode(this, "root", RootUrl, RootTitle);
				var idToNode = new Dictionary<string, SiteMapNode>();

				// build nodes
				foreach (DataRow r in ds.Tables[SourceName].Rows) {
					var node = CreateNode( r );
					idToNode[node.Key] = node;
				}
				// set hierarchy relations
				foreach (DataRow r in ds.Tables[SourceName].Rows) {
					var node = idToNode[ Convert.ToString( r[IdField] ) ];
					var parentKey = Convert.ToString(r[FkField]);
					if (r[FkField] != DBNull.Value && idToNode.ContainsKey(parentKey))
						AddNode(node, idToNode[parentKey]);
					else
						AddNode(node, rootNode);
				}

			}
			return rootNode;
		}

		protected SiteMapNode CreateNode(DataRow r) {
			var node = new SiteMapNode(this, Convert.ToString(r[IdField]));
			node.Title = Convert.ToString(r[TitleField]);
			node.Url = Convert.ToString(r[UrlField]);
			return node;
		}

		protected override SiteMapNode GetRootNodeCore() {
			return RootNode;
		}
	}
}
