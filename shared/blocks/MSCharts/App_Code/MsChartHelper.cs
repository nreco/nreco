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
using NReco;
using NReco.Web;
using System.Web.UI.DataVisualization.Charting;

public class MsChartHelper {

	public static void BindData(Chart chart, string prvName, object context, string[] seriesExpr, string labelExpr, string labelLookupName) {
		var prv = WebManager.GetService<IProvider<object,object>>(prvName);
		var ognlContext = new Dictionary<string,object>();
		ognlContext["data"] = prv.Provide(context);
		
		var ognlExpr = new NReco.OGNL.EvalOgnl();
		int seriesIdx = 0;
		foreach (var expr in seriesExpr) {
			var dataset = (IEnumerable)ognlExpr.Eval( expr, ognlContext );
			var series = chart.Series[seriesIdx];
			foreach (var val in dataset) {
				var decVal = Convert.ToDecimal(val);
				series.Points.AddY(decVal);
			}
			seriesIdx++;
		}
		/*if (!String.IsNullOrEmpty(labelExpr)) {
			var labels = (IEnumerable)ognlExpr.Eval( labelExpr, ognlContext );
			var labelsList = new List<string>();
			var labelPrv = String.IsNullOrEmpty(labelLookupName) ? null : WebManager.GetService<IProvider<object,string>>(labelLookupName);
			foreach (var lbl in labels) {
				labelsList.Add( labelPrv!=null ? labelPrv.Provide(lbl) : Convert.ToString(lbl) );
			}
			res += "&"+labelParam+String.Join("|", labelsList.ToArray() );
		}*/
	}


}