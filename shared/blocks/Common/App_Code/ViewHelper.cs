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
using NReco.Logging;
using NReco.Collections;
using NReco.Converting;
using NReco.Web;
using NReco.Web.Site;
using NReco.Web.Site.Controls;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

public static class ViewHelper {
	static ILog log = LogManager.GetLogger(typeof(ViewHelper));
	
	public static string GetRouteUrlSafe(Control ctrl, string routeName, IDictionary context) {
		try {
			return ControlExtensions.GetRouteUrl(ctrl,routeName,context);
		} catch (Exception ex) {
			log.Write(LogEvent.Debug,ex);
			return null;
		}
	}
	
	public static object GetControlValue(Control container, string ctrlId) {
		var ctrl = container.FindControl(ctrlId);
		if (ctrl==null) return null;
		if (ctrl is ITextControl)
			return ((ITextControl)ctrl).Text;
		if (ctrl is ICheckBoxControl)
			return ((ICheckBoxControl)ctrl).Checked;
		if (ctrl is IDateBoxControl)
			return ((IDateBoxControl)ctrl).Date;
		throw new Exception("Cannot extract control value from "+ctrl.GetType().ToString());
	}
	public static void SetControlValue(Control container, string ctrlId, object val) {
		var ctrl = container.FindControl(ctrlId);
		if (ctrl==null) return;
		if (ctrl is ITextControl)
			((ITextControl)ctrl).Text = Convert.ToString(val);
		if (ctrl is ICheckBoxControl)
			((ICheckBoxControl)ctrl).Checked = ConvertManager.ChangeType<bool>(val);
		if (ctrl is IDateBoxControl)
			((IDateBoxControl)ctrl).Date = ConvertManager.ChangeType<DateTime>(val);	
	}
}