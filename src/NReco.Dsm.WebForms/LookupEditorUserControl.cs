#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2011 Vitaliy Fedorchenko
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
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;

using NReco;
using NReco.Application.Web;
using NI.Ioc;


namespace NReco.Dsm.WebForms {

	public abstract class LookupEditorUserControl : EditorUserControl {

		public string LookupName { get; set; }
		public string TextFieldName { get; set; }
		public string ValueFieldName { get; set; }
		public object LookupDataContext { get; set; }

		public IEnumerable GetLookupDataSource() {
			var lookup = AppContext.ComponentFactory.GetComponent<Func<object,IEnumerable>>(LookupName);
			if (lookup==null)
				throw new Exception(String.Format("Lookup '{0}' does not exist", LookupName) );
			return ControlUtils.WrapWithDictionaryView( lookup(LookupDataContext) );
		}

	}

}