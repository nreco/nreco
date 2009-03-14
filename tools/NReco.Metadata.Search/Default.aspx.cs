using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.IO;
using System.Data;
using System.Web.UI.WebControls;

using NReco;
using NReco.Web;
using NReco.Web.Site;
using SemWeb;
using SemWeb.Inference;
using SemWeb.Query;

public partial class Default : System.Web.UI.Page {

	protected Store RdfStore;
	protected string Result;

	protected override void OnLoad(EventArgs e) {
		RdfStore = new MemoryStore();
		RdfStore.Import(
			new RdfXmlReader(@"c:\temp\_1.rdf"));

		string depRules = @"
@prefix n: <urn:schemas-nreco:metadata:terms#>.
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.

{ ?a n:dependentFrom ?b . ?b n:dependentFrom ?c .} => {?a n:dependentFrom ?c}.
{ ?a n:dependentFrom ?b } => { ?b n:usedBy ?a}.
{ ?a n:usedBy ?b . ?b n:usedBy ?c .} => {?a n:usedBy ?c}.
";

		Euler engine = new Euler(new N3Reader(new StringReader(depRules)));

		RdfStore.AddReasoner(new RDFS(RdfStore));
		RdfStore.AddReasoner(engine);

		string rdfQuery = @"
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
@prefix p: <urn:schemas-nreco:metadata:dotnet:property#>.
@prefix t: <urn:schemas-nreco:metadata:dotnet:type#>.
@prefix w: <file:///d:/Vitalik/GoogleCode/NReco/examples/NReco.Examples.WebApp/web/#>.
@prefix cso: <http://cos.ontoware.org/cso#>.
@prefix n: <urn:schemas-nreco:metadata:terms#>.
w:db n:usedBy ?t2.
";		
		
		Query query = new GraphMatch(new N3Reader(new StringReader(rdfQuery)));
		StringWriter wr = new StringWriter();
		QueryResultSink sink = new SparqlXmlQuerySink(wr);
		query.Run(RdfStore, sink);
		Result = wr.ToString();

		base.OnLoad(e);
	}


}
