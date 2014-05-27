using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using System.Data;

using NI.Data;

namespace NReco.Dsm.Data {
	
	/// <summary>
	/// Data provider used by DALC DSM
	/// </summary>
	public class DataProvider {

		public IDalc Dalc { get; private set; }

		public string Relex { get; private set; }

		public string[] ExtendedProperties { get; set; }

		public DataProvider(IDalc dalc, string relex) {
			Dalc = dalc;
			Relex = relex;
		}

		protected Query PrepareQuery(IDictionary<string,object> context) {
			var relex = new NI.Data.SimpleStringTemplate(Relex).FormatTemplate(context);
			var q = new NI.Data.RelationalExpressions.RelExParser().Parse(relex);
			if (q.Condition != null)
				DataHelper.SetQueryVariables(q.Condition, (varNode) => {
					if (context.ContainsKey(varNode.Name))
						varNode.Set(context[varNode.Name]);
					else
						varNode.Unset();
				});
			if (ExtendedProperties!=null) {
				q.ExtendedProperties = new Dictionary<string,object>();
				foreach (var extProp in ExtendedProperties)
					q.ExtendedProperties[extProp] = context.ContainsKey(extProp) ? context[extProp] : null;
			}
			return q;			
		}

		public object LoadValue(IDictionary<string,object> context) {
			return Dalc.LoadValue(PrepareQuery(context));
		}

		public object[] LoadAllValues(IDictionary<string, object> context) {
			return Dalc.LoadAllValues(PrepareQuery(context));
		}

		public IDictionary LoadRecord(IDictionary<string, object> context) {
			return Dalc.LoadRecord(PrepareQuery(context));
		}

		public IDictionary[] LoadAllRecords(IDictionary<string, object> context) {
			return Dalc.LoadAllRecords(PrepareQuery(context));
		}

		public DataTable LoadDataTable(IDictionary<string, object> context) {
			var ds = new DataSet();
			return Dalc.Load( PrepareQuery(context), ds );
		}

	}
}
