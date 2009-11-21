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
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;

using NReco;
using NReco.Web;
using NReco.Web.Site;
using SemWeb;
using NReco.SemWeb;
using NReco.SemWeb.Model;

public partial class PropertyValue : NReco.Web.ActionUserControl {

	public PropertyView Property { get; set; }

	public override void DataBind() {
		base.DataBind();
		if (Property.HasValue && Property.Values.Count==1) {
			Controls.Add( LoadControl("renderers/SingleObject.ascx") );
		} else if (Property.HasValue && Property.Values.Count>1) {
			Controls.Add( LoadControl("renderers/ObjectList.ascx") );
		} else if (Property.HasReference && Property.References.Count==1) {
			Controls.Add( LoadControl("renderers/SingleReference.ascx") );
		} else if (Property.HasReference && Property.References.Count>1) {
			Controls.Add( LoadControl("renderers/ReferenceList.ascx") );
		}
		if (Controls.Count>0)
			Controls[0].DataBind();
	}


}
