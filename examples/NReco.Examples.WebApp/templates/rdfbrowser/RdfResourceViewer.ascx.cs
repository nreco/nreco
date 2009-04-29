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
	int MaxShortRelationCount = 5;

	SelectableSource _RdfStore = null;
	public SelectableSource RdfStore {
		get {
			if (_RdfStore == null) {
				var dbStore = WebManager.GetService<SelectableSource>(RdfStoreName);
				var store = new Store();
				store.AddSource(dbStore);

				var rdfStore = new MemoryStore();
				rdfStore.Import(new RdfXmlReader(@"c:\temp\_1.rdf"));				
				store.AddSource(rdfStore);

				_RdfStore = store;
			}
			return _RdfStore;
		}
	}

	protected override void OnLoad(EventArgs e) {
		RdfStoreName = "dbRdfStore";
		CurrentResourceUri = Request["resource"];
		DataBind();
	}

	protected IDictionary<string, ReferenceListProperty> FromRelations;
	protected IDictionary<string, ReferenceListProperty> ToRelations;
	
	protected IList<SingleValueProperty> SingleValues;
	protected string CurrentResourceLabel;
	protected IList<SingleReference> FromSingleReferences;
	protected IList<SingleReference> ToSingleReferences;
	protected IList<ReferenceListProperty> FromShortRelations;
	protected IList<ReferenceListProperty> ToShortRelations;
	protected IList<ReferenceListProperty> LongRelations;
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
		FromRelations = new Dictionary<string, ReferenceListProperty>();
		FromSingleReferences = new List<SingleReference>();
		ToRelations = new Dictionary<string, ReferenceListProperty>();
		ToSingleReferences = new List<SingleReference>();
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
				if (lblLiteral != null) {
					lbl = lblLiteral.Value;
				}
				SingleValues.Add(new SingleValueProperty { Property = entry.Key, Label = lbl, Value = ((Literal)val).Value });
				continue;
			}
			// single-value references
			if (entry.Value.Count == 1 && entry.Value[0] is Entity) {
				FromSingleReferences.Add(
						new SingleReference { 
							Label = GetLink( entry.Key ),
							Link = GetLink( (Entity)entry.Value[0] )
						}
					);
				continue;
			}
			

			// other predicates
			if (!FromRelations.ContainsKey(entry.Key.Uri))
				FromRelations[entry.Key.Uri] = new ReferenceListProperty {
					Label = GetLink(entry.Key),
					Links = new List<EntityLink>()
				};
			for (int i = 0; i < entry.Value.Count; i++)
				if (entry.Value[i] is Entity && !(entry.Value[i] is BNode))
					FromRelations[entry.Key.Uri].Links.Add( GetLink( (Entity)entry.Value[i] ) );

		}


		foreach (var entry in reverseMatches.Groups) {
			// single-value references
			if (entry.Value.Count == 1) {
				ToSingleReferences.Add(
						new SingleReference {
							Label = GetLink(entry.Key),
							Link = GetLink((Entity)entry.Value[0])
						}
					);
				continue;
			}

			if (!ToRelations.ContainsKey(entry.Key.Uri))
				ToRelations[entry.Key.Uri] = new ReferenceListProperty {
					Label = GetLink(entry.Key),
					Links = new List<EntityLink>()
				};
			for (int i = 0; i < entry.Value.Count; i++)
				if (entry.Value[i] is Entity && !(entry.Value[i] is BNode))
					ToRelations[entry.Key.Uri].Links.Add(GetLink((Entity)entry.Value[i]));
			
		}
		PrepareRelations();

		if (SingleValues.Count == 0) {
			AboutResourceMessage = "No simple-type properies for this resource.";
		}
		if (directMatches.Groups.Count == 0 && reverseMatches.Groups.Count==0) {
			AboutResourceMessage = "This resource is unknown.";
		}

		base.DataBind();
	}

	protected void PrepareRelations() {
		FromShortRelations = new List<ReferenceListProperty>();
		ToShortRelations = new List<ReferenceListProperty>();
		LongRelations = new List<ReferenceListProperty>();

		foreach (var fromRel in FromRelations.Values) {
			if (fromRel.Links.Count > MaxShortRelationCount)
				LongRelations.Add(fromRel);
			else
				FromShortRelations.Add(fromRel);
		}
		foreach (var toRel in ToRelations.Values) {
			if (toRel.Links.Count > MaxShortRelationCount)
				LongRelations.Add(toRel);
			else
				ToShortRelations.Add(toRel);
		}
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

	public class SingleReference {
		public EntityLink Label { get; set; }
		public EntityLink Link { get; set; }
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
			Resource r = Reverse ? st.Subject : st.Object;
			if (!Groups[st.Predicate].Contains(r))
				Groups[st.Predicate].Add(r);
			return true;
		}
	}

}
