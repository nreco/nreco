using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using System.Data;
using NUnit.Framework;
using NReco;
using NReco.Metadata;
using NReco.Metadata.Dalc;
using NI.Data.Dalc;
using SemWeb;
using Moq;

namespace NReco.Tests {

	[TestFixture]
	public class DalcRdfStoreTests {

		protected void AddRow(DataTable tbl, params object[] values) {
			var r = tbl.NewRow();
			for (int i = 0; i < tbl.Columns.Count; i++)
				r[tbl.Columns[i]] = values[i];
			tbl.Rows.Add(r);
		}

		protected IDalc PrepareDalc() {
			var dalc = new DatasetDalc();
			var ds = new DataSet();
			//
			var accountsTbl = ds.Tables.Add("accounts");
			accountsTbl.Columns.Add("id", typeof(int));
			accountsTbl.Columns.Add("name", typeof(string));
			accountsTbl.Columns.Add("age", typeof(int));
			accountsTbl.Columns.Add("number", typeof(int));
			AddRow(accountsTbl, 1, "Vitalik", 26, 2);
			AddRow(accountsTbl, 2, "Zhenya", 2, 0);
			AddRow(accountsTbl, 3, "Bill", 52, 100);

			dalc.PersistedDS = ds;
			return dalc;
		}

		[Test]
		public void SelectByTemplateTest() {
			var store = new DalcRdfStore();
			store.Dalc = PrepareDalc();
			string ns_foaf_name = "http://xmlns.com/foaf/0.1/name";
			string ns_accounts = "urn:test:accounts";
			string ns_number = "urn:test:number";
			store.SourceDescriptors = new[] {
				new DalcRdfStore.SourceDescriptor() {
					Ns = ns_accounts,
					IdFieldName = "id",
					RdfType = NS.Rdfs.Class,
					SourceName = "accounts",
					Fields = new [] {
						new DalcRdfStore.FieldDescriptor() {
							FieldName = "name",
							Ns = ns_foaf_name,
							RdfType = NS.Rdfs.Property
						},
						new DalcRdfStore.FieldDescriptor() {
							FieldName = "age",
							Ns = "urn:test:age",
							RdfType = NS.Rdfs.Property
						},
						new DalcRdfStore.FieldDescriptor() {
							FieldName = "number",
							Ns = ns_number,
							RdfType = NS.Rdfs.Property
						}
					}
				}
			};
			store.Init();
			//System.Diagnostics.Debugger.Break();
			var ns_account1 = "urn:test:accounts#1";
			var ns_account2 = "urn:test:accounts#2";
			var ns_age = "urn:test:age";
			Assert.IsFalse(store.Contains(new Statement(ns_account1, ns_age, new Literal("2"))));
			Assert.IsTrue(store.Contains(new Statement(ns_account2, ns_age, new Literal("2"))));
			Assert.IsTrue(store.Contains(new Statement(null, ns_age, new Literal("2"))));

			var sinkMock = new Mock<StatementSink>();
			// test case: no subject
			store.Select(new Statement(null, ns_age, new Literal("2")), sinkMock.Object);
			sinkMock.Verify(a => a.Add(new Statement(ns_account2, ns_age, new Literal("2"))), Times.Exactly(1));

			var sinkMock2 = new Mock<StatementSink>();
			// test case: only subject
			store.Select(new Statement(ns_account1, null, null), sinkMock2.Object);
			sinkMock2.Verify(a => a.Add(new Statement(ns_account1, ns_age, new Literal("26"))), Times.Exactly(1));
			sinkMock2.Verify(a => a.Add(new Statement(ns_account1, ns_number, new Literal("2"))), Times.Exactly(1));
			sinkMock2.Verify(a => a.Add(new Statement(ns_account1, ns_foaf_name, new Literal("Vitalik"))), Times.Exactly(1));
			sinkMock2.Verify(a => a.Add(new Statement(ns_account1, NS.Rdf.type, (Entity)ns_accounts)), Times.Exactly(1));

			// test case: select filter
			var sinkMock3 = new Mock<StatementSink>();
			store.Select(
				new SelectFilter(null, new[] { (Entity)ns_age, (Entity)ns_number }, new[] { new Literal("2") }, null), sinkMock3.Object);
			sinkMock3.Verify(a => a.Add(new Statement(ns_account1, ns_number, new Literal("2") )), Times.Exactly(1));
			sinkMock3.Verify(a => a.Add(new Statement(ns_account2, ns_age, new Literal("2"))), Times.Exactly(1));
			
		}




	}
}
