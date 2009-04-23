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
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

public partial class RdfResourceViewer : NReco.Web.ActionUserControl {

	public string CurrentResourceUri { get; set; }
	public string RdfStoreName { get; set; }

	SelectableSource _RdfStore = null;
	public SelectableSource RdfStore {
		get { 
			if (_RdfStore==null)
				_RdfStore = WebManager.GetService<SelectableSource>(RdfStoreName);
			return _RdfStore;
		}
	}

	protected override void OnLoad(EventArgs e) {
		RdfStoreName = "dbRdfStore";
		CurrentResourceUri = Request["resource"];

		DataBind();
	}

	protected IList<SingleValueProperty> SingleValues;

	public override void DataBind() {
		// select all triplets 
		var result = new GroupStatementSink();
		RdfStore.Select(new Statement(CurrentResourceUri, null, null), result);

		SingleValues = new List<SingleValueProperty>();
		foreach (var entry in result.Groups)
			if (entry.Value.Count == 1) {
				var val = entry.Value[0];
				var lbl = RdfStore.SelectLiteral(new Statement(entry.Key, NS.Rdfs.labelEntity, null));
				//Response.Write(entry.Key.Uri);
				if (lbl != null && val is Literal) {
					SingleValues.Add(new SingleValueProperty { Property = entry.Key, Label = lbl.Value, Value = ((Literal)val).Value });
				}
			}

		base.DataBind();
	}

	public class SingleValueProperty {
		public Entity Property { get; set; }
		public string Label { get; set; }
		public object Value { get; set; }
	}



	public class GroupStatementSink : StatementSink {
		public IDictionary<Entity, IList<Resource>> Groups { get; private set; }

		public GroupStatementSink() {
			Groups = new Dictionary<Entity, IList<Resource>>();
		}

		public bool Add(Statement st) {
			if (!Groups.ContainsKey(st.Predicate))
				Groups[st.Predicate] = new List<Resource>();
			Groups[st.Predicate].Add(st.Object);
			return true;
		}
	}

}
