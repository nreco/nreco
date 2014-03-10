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

using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace NReco.Application.Web.Forms {
	
	/// <summary>
	/// This class is used by NReco layout model transformation.
	/// </summary>
	public class DataContextHolder : PlaceHolder {

		public object DataContext { get; set; }

		public DataContextHolder() {
		}

		public object GetDataContext() {
			OnDataBinding(EventArgs.Empty);
			return DataContext;
		}

		public override void DataBind() {
			// ignore external databind stage
		}


	}
}
