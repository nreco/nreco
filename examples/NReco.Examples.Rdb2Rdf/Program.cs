#region License
/*
 * NReco library (http://code.google.com/p/nreco/)
 * Copyright 2009 Vitaliy Fedorchenko
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
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using NI.Data.Dalc;
using NReco.Metadata;
using NReco.Metadata.Dalc;
using SemWeb;
using SemWeb.Inference;

namespace NReco.Examples.Rdb2Rdf {

	/// <summary>
	/// RDB-to-RDF bridge sample.
	/// </summary>
	public class Program {

		static void Main(string[] args) {
			var prog = new Program();
			
			// bridge is based on Open NIC.NET DALC
			// in this sample DatasetDalc is used for the sake of simplisity
			var dalc = prog.PrepareDalc();
			
			var dalc2Rdf = prog.PrepareRdfMapping(dalc);

			prog.TestReasoner(dalc2Rdf);

			Console.WriteLine("Press any key for RDF export (N3).");
			Console.ReadKey();
			prog.ExportToN3(dalc2Rdf);

			Console.ReadKey();
		}

		protected void TestReasoner(DalcRdfStore dalcStore) {
			var store = new Store(dalcStore);
			Euler engine = new Euler(new N3Reader(new StringReader(eulerRules)));
			store.AddReasoner(engine);

			Console.WriteLine(
				"Is Bill a child of Adam? "+
				store.Contains(
					new Statement(baseNs + "persons#1", baseNs + "terms#child", (Entity)(baseNs + "persons#4"))).ToString());
			Console.WriteLine(
				"Is Bill a child of Eve? " +
				store.Contains(
					new Statement(baseNs + "persons#2", baseNs + "terms#child", (Entity)(baseNs + "persons#4"))).ToString());

			Console.Write("Children of Eve: ");
			var res = store.Select(new Statement(baseNs + "persons#2", baseNs + "terms#child", null));
			foreach (var st in res)
				Console.Write(st.Object.Uri+" ");
			Console.WriteLine();
		}

		static string baseNs = "http://www.nreco.qsh.eu/rdf/";
		static string ns_foaf_name = "http://xmlns.com/foaf/0.1/name";

		protected DalcRdfStore PrepareRdfMapping(IDalc dalc) {
			var dalc2Rdf = new DalcRdfStore();
			dalc2Rdf.Dalc = dalc;

			dalc2Rdf.Sources = new[] {
				new DalcRdfStore.SourceDescriptor() {
					Ns = baseNs+"persons",
					IdFieldName = "id",
					IdFieldType = typeof(int),
					RdfType = NS.Rdfs.Class,
					SourceName = "persons",
					Fields = new [] {
						new DalcRdfStore.FieldDescriptor() {
							FieldName = "name",
							Ns = ns_foaf_name,
							RdfType = NS.Rdfs.Property,
							FieldType = typeof(string)
						},
						new DalcRdfStore.FieldDescriptor() {
							FieldType = typeof(int),
							FieldName = "mother_id",
							Ns = baseNs+"terms#mother",
							RdfType = NS.Rdfs.Property,
							FkSourceName = "persons"
						},
						new DalcRdfStore.FieldDescriptor() {
							FieldType = typeof(int),
							FieldName = "father_id",
							Ns = baseNs+"terms#father",
							RdfType = NS.Rdfs.Property,
							FkSourceName = "persons"
						}
					}
				}
			};
			dalc2Rdf.Init();
			return dalc2Rdf;
		}

		protected void ExportToN3(DalcRdfStore store) {
			using (var n3wr = new N3Writer(Console.Out)) {
				n3wr.Namespaces.AddNamespace("http://www.nreco.qsh.eu/rdf/", "nreco");
				n3wr.Namespaces.AddNamespace(NS.Rdf.BASE, "rdf");
				n3wr.Namespaces.AddNamespace(NS.Rdfs.BASE, "rdfs");
				store.Select(n3wr);
			}
		}

		/// <summary>
		/// reasoner rules: parent and child predicates.
		/// </summary>
		string eulerRules = @"
@prefix t: <http://www.nreco.qsh.eu/rdf/terms#>.
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.

{ ?a t:mother ?b } => {?a t:parent ?b}.
{ ?a t:father ?b } => {?a t:parent ?b}.
{ ?a t:parent ?b } => { ?b t:child ?a}.
";


		/// <summary>
		/// Composes sample DALC based on DataSet object.
		/// In real life you will use DbDalc implementation.
		/// </summary>
		protected IDalc PrepareDalc() {
			var dalc = new DatasetDalc();
			var ds = new DataSet();
			//
			var accountsTbl = ds.Tables.Add("persons");
			accountsTbl.Columns.Add("id", typeof(int));
			accountsTbl.Columns.Add("name", typeof(string));
			accountsTbl.Columns.Add("mother_id", typeof(int)).AllowDBNull = true;
			accountsTbl.Columns.Add("father_id", typeof(int)).AllowDBNull = true;
			AddRow(accountsTbl, 1, "Adam");
			AddRow(accountsTbl, 2, "Eve");
			AddRow(accountsTbl, 3, "Jane", 2, 1);
			AddRow(accountsTbl, 4, "Bill", 2, 0);
			AddRow(accountsTbl, 5, "Joe", 3, 4);
			AddRow(accountsTbl, 6, "Anna", 0, 5);

			dalc.PersistedDS = ds;
			return dalc;
		}
		protected void AddRow(DataTable tbl, params object[] values) {
			var r = tbl.NewRow();
			for (int i = 0; i < tbl.Columns.Count; i++)
				if (i<values.Length)
					r[tbl.Columns[i]] = values[i];
			tbl.Rows.Add(r);
		}

	}
}
