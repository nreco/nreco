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
	protected string CurrentResourceLabel;
	protected IDictionary<string,ReferenceListProperty> DirectRelations;
	protected IDictionary<string, ReferenceListProperty> ReverseRelations;
	protected string AboutResourceMessage = null;

	static IDictionary<string, string> NsBaseToLabelPrefix = new Dictionary<string, string> {
		{NS.Rdf.BASE,"Rdf"},
		{NS.Rdfs.BASE,"Rdfs"},
		{NS.Owl.BASE,"Owl"}
	};

	protected string GetFriendlyUriLabel(string uri) {
		foreach (var nsBasePrefix in NsBaseToLabelPrefix)
			if (uri.StartsWith(nsBasePrefix.Key)) {
				return String.Format("{0}:{1}", nsBasePrefix.Value, uri.Substring(nsBasePrefix.Key.Length));
			}
		return uri;
	}

	protected EntityLink GetLink(Entity e) {
		var lbl = RdfStore.SelectLiteral(new Statement(e, NS.Rdfs.labelEntity, null));
		var link = new EntityLink { Uri = e.Uri, Text = GetFriendlyUriLabel( e.Uri ) };
		if (lbl != null)
			link.Text = lbl.Value;
		return link; 
	}

	public override void DataBind() {
		// select both direct/reverse relations
		var directMatches = new GroupStatementSink(false);
		RdfStore.Select(new Statement(CurrentResourceUri, null, null), directMatches);
		var reverseMatches = new GroupStatementSink(true);
		RdfStore.Select(new Statement(null, null, (Entity)CurrentResourceUri), reverseMatches);

		SingleValues = new List<SingleValueProperty>();
		DirectRelations = new Dictionary<string, ReferenceListProperty>();
		ReverseRelations = new Dictionary<string, ReferenceListProperty>();
		CurrentResourceLabel = GetFriendlyUriLabel(CurrentResourceUri);

		foreach (var entry in directMatches.Groups) {

			// rdfs:label handling
			if (entry.Key == NS.Rdfs.labelEntity && entry.Value[0] is Literal) {
				CurrentResourceLabel = ((Literal)entry.Value[0]).Value;
				continue;
			}
			// single-value literals
			if (entry.Value.Count == 1 && entry.Value[0] is Literal) {
				var val = entry.Value[0];
				var lbl = GetFriendlyUriLabel( entry.Key.Uri );
				var lblLiteral = RdfStore.SelectLiteral(new Statement(entry.Key, NS.Rdfs.labelEntity, null));
				if (lbl != null) {
					lbl = lblLiteral.Value;
				}
				SingleValues.Add(new SingleValueProperty { Property = entry.Key, Label = lbl, Value = ((Literal)val).Value });
				continue;
			}

			// other predicates
			if (entry.Value[0] is Entity) {
				if (!DirectRelations.ContainsKey(entry.Key.Uri))
					DirectRelations[entry.Key.Uri] = new ReferenceListProperty {
						Label = GetLink(entry.Key),
						Links = new List<EntityLink>()
					};
				for (int i = 0; i < entry.Value.Count; i++)
					DirectRelations[entry.Key.Uri].Links.Add( GetLink( (Entity)entry.Value[i] ) );
				continue;
			}

		}


		foreach (var entry in reverseMatches.Groups) {
			if (!ReverseRelations.ContainsKey(entry.Key.Uri))
				ReverseRelations[entry.Key.Uri] = new ReferenceListProperty {
					Label = GetLink(entry.Key),
					Links = new List<EntityLink>()
				};
			for (int i = 0; i < entry.Value.Count; i++)
				ReverseRelations[entry.Key.Uri].Links.Add(GetLink((Entity)entry.Value[i]));
			
		}

		if (SingleValues.Count == 0) {
			AboutResourceMessage = "No simple-type properies for this resource.";
		}
		if (directMatches.Groups.Count == 0 && reverseMatches.Groups.Count==0) {
			AboutResourceMessage = "This resource is unknown.";
		}

		base.DataBind();
	}

	public class SingleValueProperty {
		public Entity Property { get; set; }
		public string Label { get; set; }
		public object Value { get; set; }
	}

	public class ReferenceListProperty {
		public EntityLink Label { get; set; }
		public IList<EntityLink> Links { get; set; }
	}

	public class EntityLink {
		public string Uri { get; set; }
		public string Text { get; set; }
	}


	public class GroupStatementSink : StatementSink {
		public IDictionary<Entity, IList<Resource>> Groups { get; private set; }
		bool Reverse = false;

		public GroupStatementSink(bool isRev) {
			Reverse = isRev;
			Groups = new Dictionary<Entity, IList<Resource>>();
		}

		public bool Add(Statement st) {
			if (!Groups.ContainsKey(st.Predicate))
				Groups[st.Predicate] = new List<Resource>();
			Groups[st.Predicate].Add(Reverse ? st.Subject : st.Object);
			return true;
		}
	}

}
