#region License
/*
 * NReco library (http://code.google.com/p/nreco/)
 * Copyright 2008 Vitaliy Fedorchenko
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
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace NReco.Web {
	
	/// <summary>
	/// Label context class.
	/// </summary>
	public class LabelContext : NameValueContext {

		/// <summary>
		/// Label origin type
		/// </summary>
		public Type OriginType { get; private set; }

		/// <summary>
		/// Label origin control
		/// </summary>
		public Control Origin { get; private set; }
		
		/// <summary>
		/// Label string
		/// </summary>
		public string Label { get; private set; }

		public LabelContext(string lbl) {
			Label = lbl;
		}

		public LabelContext(string lbl, Control origin) {
			Label = lbl;
			Origin = origin;
			OriginType = origin != null ? origin.GetType() : null;
		}

		public LabelContext(string lbl, Type originType) {
			Label = lbl;
			OriginType = originType;
		}

		public override string ToString() {
			return Label;
		}

	}

}
