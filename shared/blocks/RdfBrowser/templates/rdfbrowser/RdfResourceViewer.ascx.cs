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
using NReco.SemWeb.Model;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

public partial class RdfResourceViewer : NReco.Web.ActionUserControl {

	public string CurrentResourceUri { get; set; }
	public string RdfStoreName { get; set; }

	SelectableSource _RdfStore = null;
	public SelectableSource RdfStore {
		get {
			if (_RdfStore == null) {
				var dbStore = WebManager.GetService<SelectableSource>(RdfStoreName);
				var store = new Store();
				store.AddSource(dbStore);
				
				var rdfStore = new MemoryStore();
				rdfStore.Import(new RdfXmlReader(@"d:\Vitalik\GoogleCode\NReco\shared\rdf\rdfs.owl"));				
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

	protected ResourceView CurrentResource;
	
	protected IList<PropertyView> Right;
	protected IList<PropertyView> Left;
	protected IList<PropertyView> Center;
	
	protected string AboutResourceMessage = null;

	static IDictionary<string, string> NsBaseToLabelPrefix = new Dictionary<string, string> {
		{NS.Rdf.BASE,"Rdf"},
		{NS.Rdfs.BASE,"Rdfs"},
		{NS.Owl.BASE,"Owl"}
	};

	protected string GetFriendlyLabel(ResourceView res) {
		if (res.Label!=null)
			return res.Label;
		var uri = res.Uid.Uri;
		foreach (var nsBasePrefix in NsBaseToLabelPrefix)
			if (uri.StartsWith(nsBasePrefix.Key)) {
				return String.Format("{0}:{1}", nsBasePrefix.Value, uri.Substring(nsBasePrefix.Key.Length));
			}
		return uri;
	}

	public override void DataBind() {
		CurrentResource = new ResourceView(CurrentResourceUri,RdfStore);
		
		Center = new List<PropertyView>();
		Right = new List<PropertyView>();
		Left = new List<PropertyView>();
		
		foreach (var prop in CurrentResource.Properties) {
			if ( (prop.HasValue && prop.Values.Count==1) || (prop.HasReference && prop.References.Count==1) ) {
				if (prop.Property.Uid!=NS.Rdfs.labelEntity)
					Center.Add( prop );
			}
			if (prop.HasReference && prop.References.Count>1) {
				Right.Add( prop );
			}
			if (prop.HasValue && prop.Values.Count>1) {
				Left.Add( prop );
			}
		}

		if (CurrentResource.Properties.Count == 0) {
			AboutResourceMessage = "No simple-type properies for this resource.";
		}
		if (CurrentResource.Properties.Count==0) {
			AboutResourceMessage = "This resource is unknown.";
		}

		base.DataBind();
	}


}
