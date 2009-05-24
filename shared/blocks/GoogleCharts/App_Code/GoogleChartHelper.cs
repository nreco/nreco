using System;
using System.Collections;
using System.Collections.Generic;
using NReco;
using NReco.Web;

public class GoogleChartHelper {

	public static string PrepareDataUrl(string prvName, object context, string[] seriesExpr, string labelParam, string labelExpr, string labelLookupName) {
		var prv = WebManager.GetService<IProvider<object,object>>(prvName);
		var ognlContext = new Dictionary<string,object>();
		ognlContext["data"] = prv.Provide(context);
		
		var series = new List<string>();
		var minMax = new List<string>();
		var ognlExpr = new NReco.OGNL.EvalOgnl();
		foreach (var expr in seriesExpr) {
			var dataset = (IEnumerable)ognlExpr.Eval( expr, ognlContext );
			var datasetList = new List<string>();
			decimal min = 0;
			decimal max = 0;
			foreach (var val in dataset) {
				var decVal = Convert.ToDecimal(val);
				datasetList.Add( String.Format("{0:0.#}", decVal) );
				if (decVal<min) min = decVal;
				if (decVal>max) max = decVal;
			}
			series.Add( String.Join(",",datasetList.ToArray() ) );
			minMax.Add( String.Format("{0:0.#}", min) );
			minMax.Add( String.Format("{0:0.#}", max) );
		}
		var res = String.Format("chd=t:{0}&chds={1}", String.Join("|",series.ToArray()), String.Join(",", minMax.ToArray() ) );
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