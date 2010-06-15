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
using System.Globalization;
using System.Collections.Generic;
using NReco;
using NReco.Web;

public class GoogleChartHelper {

	public static string PrepareDataUrl(string prvName, object context, string[] seriesExpr, string labelParam, string labelExpr, string labelLookupName) {
		var prv = WebManager.GetService<IProvider<object,object>>(prvName);
		var ognlContext = new Dictionary<string,object>();
		ognlContext["data"] = prv.Provide(context);
		
		var series = new List<string>();
		decimal allMin = 0;
		decimal allMax = 0;
		var ognlExpr = new NReco.OGNL.EvalOgnl();
		foreach (var expr in seriesExpr) {
			var dataset = (IEnumerable)ognlExpr.Eval( expr, ognlContext );
			var datasetList = new List<string>();
			decimal min = 0;
			decimal max = 0;
			foreach (var val in dataset) {
				var decVal = Convert.ToDecimal(val);
				datasetList.Add( String.Format( CultureInfo.InvariantCulture, "{0:0.#}", decVal) );
				if (decVal<min) min = decVal;
				if (decVal>max) max = decVal;
			}
			series.Add( String.Join(",",datasetList.ToArray() ) );
			
			if (allMin>min) allMin = min;
			if (allMax<max) allMax = max;
		}
		var res = String.Format( CultureInfo.InvariantCulture, "chd=t:{0}&chds={1:0.##},{2:0.##}&chxr=1,{1:0.##},{2:0.##},{3}", String.Join("|",series.ToArray()), allMin,allMax, (allMax-allMin)/5  );
		if (!String.IsNullOrEmpty(labelExpr)) {
			var labels = (IEnumerable)ognlExpr.Eval( labelExpr, ognlContext );
			var labelsList = new List<string>();
			var labelPrv = String.IsNullOrEmpty(labelLookupName) ? null : WebManager.GetService<IProvider<object,string>>(labelLookupName);
			foreach (var lbl in labels) {
				labelsList.Add( labelPrv!=null ? labelPrv.Provide(lbl) : Convert.ToString(lbl) );
			}
			res += "&"+labelParam+String.Join("|", labelsList.ToArray() );
		}
		return res;
	}


}