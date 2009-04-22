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
			accountsTbl.Columns.Add("aff_id", typeof(int));
			AddRow(accountsTbl, 1, "Vitalik", 26, 2, 3);
			AddRow(accountsTbl, 2, "Zhenya", 2, 0, 1);
			AddRow(accountsTbl, 3, "Bill", 52, 100, 0);

			dalc.PersistedDS = ds;
			return dalc;
		}

		protected Mock<StatementSink> GetSinkMock() {
			var m = new Mock<StatementSink>();
			m.Setup(a => a.Add(It.IsAny<Statement>())).Returns(true);
			return m;
		}

		[Test]
		public void SelectByTemplateTest() {
			var store = new DalcRdfStore();
			store.Dalc = PrepareDalc();
			string ns_foaf_name = "http://xmlns.com/foaf/0.1/name";
			string ns_accounts = "urn:test:accounts";
			string ns_number = "urn:test:number";
			string ns_id = "urn:test:id";
			string ns_aff_id = "urn:test:aff_id";
			store.Sources = new[] {
				new DalcRdfStore.SourceDescriptor() {
					Ns = ns_accounts,
					IdFieldName = "id",
					RdfType = NS.Rdfs.Class,
					SourceName = "accounts",
					Fields = new [] {
						new DalcRdfStore.FieldDescriptor() {
							FieldName = "name",
							Ns = ns_foaf_name,
							RdfType = NS.Rdfs.Property,
							FieldType = typeof(string)
						},
						new DalcRdfStore.FieldDescriptor() {
							FieldName = "age",
							FieldType = typeof(int),
							Ns = "urn:test:age",
							RdfType = NS.Rdfs.Property
						},
						new DalcRdfStore.FieldDescriptor() {
							FieldName = "number",
							FieldType = typeof(int),
							Ns = ns_number,
							RdfType = NS.Rdfs.Property
						},
						new DalcRdfStore.FieldDescriptor() {
							FieldType = typeof(int),
							FieldName = "id",
							Ns = ns_id,
							RdfType = NS.Rdfs.Property
						},
						new DalcRdfStore.FieldDescriptor() {
							FieldType = typeof(int),
							FieldName = "aff_id",
							Ns = ns_aff_id,
							RdfType = NS.Rdfs.Property,
							FkSourceName = "accounts"
						}

					}
				}
			};
			store.Init();
			//System.Diagnostics.Debugger.Break();
			var ns_account1 = "urn:test:accounts#1";
			var ns_account2 = "urn:test:accounts#2";
			var ns_account3 = "urn:test:accounts#3";
			var ns_age = "urn:test:age";
			Assert.IsFalse(store.Contains(new Statement(ns_account1, ns_age, new Literal("2"))));
			Assert.IsTrue(store.Contains(new Statement(ns_account2, ns_age, new Literal("2"))));
			Assert.IsTrue(store.Contains(new Statement(null, ns_age, new Literal("2"))));

			var sinkMock = GetSinkMock();
			// test case: no subject
			store.Select(new Statement(null, ns_age, new Literal("2")), sinkMock.Object);
			sinkMock.Verify(a => a.Add(new Statement(ns_account2, ns_age, new Literal("2"))), Times.Exactly(1));

			var sinkMock2 = GetSinkMock();
			// test case: only subject
			store.Select(new Statement(ns_account1, null, null), sinkMock2.Object);
			sinkMock2.Verify(a => a.Add(new Statement(ns_account1, ns_age, new Literal("26"))), Times.Exactly(1));
			sinkMock2.Verify(a => a.Add(new Statement(ns_account1, ns_number, new Literal("2"))), Times.Exactly(1));
			sinkMock2.Verify(a => a.Add(new Statement(ns_account1, ns_foaf_name, new Literal("Vitalik"))), Times.Exactly(1));
			sinkMock2.Verify(a => a.Add(new Statement(ns_account1, NS.Rdf.type, (Entity)ns_accounts)), Times.Exactly(1));
			sinkMock2.Verify(a => a.Add(new Statement(ns_account1, ns_aff_id, (Entity)ns_account3 )), Times.Exactly(1));

			// test case: select filter
			var sinkMock3 = GetSinkMock();
			store.Select(
				new SelectFilter(null, new[] { (Entity)ns_age, (Entity)ns_number }, new[] { new Literal("2") }, null), sinkMock3.Object);
			sinkMock3.Verify(a => a.Add(new Statement(ns_account1, ns_number, new Literal("2") )), Times.Exactly(1));
			sinkMock3.Verify(a => a.Add(new Statement(ns_account2, ns_age, new Literal("2"))), Times.Exactly(1));

			var sinkMock4 = GetSinkMock();
			store.Select(new Statement(null, ns_aff_id, (Entity)ns_account1), sinkMock4.Object);
			sinkMock4.Verify(a => a.Add(new Statement(ns_account2, ns_aff_id, (Entity)ns_account1 )), Times.Exactly(1));

			// test case: schema selects
			Assert.IsTrue(store.Contains(new Statement(ns_aff_id, NS.Rdf.type, NS.Rdfs.PropertyEntity)));
			Assert.IsTrue(store.Contains(new Statement(ns_aff_id, NS.Rdfs.domainEntity, (Entity)ns_accounts )));

			//store.Select(new N3Writer(Console.Out));

			int schemaStatements = 0;
			var sinkMock5 = GetSinkMock();
			sinkMock5.Setup(a => a.Add(It.IsAny<Statement>())).Callback(() => schemaStatements++).Returns(true);
			store.Select(new Statement(null, NS.Rdf.typeEntity, NS.Rdfs.ClassEntity), sinkMock5.Object);
			Assert.AreEqual(1, schemaStatements);
			sinkMock5.Verify(a => a.Add(new Statement(ns_accounts, NS.Rdf.typeEntity, NS.Rdfs.ClassEntity)), Times.Exactly(1));
			
			store.Select(new Statement(null, NS.Rdfs.domainEntity, (Entity)ns_accounts), sinkMock5.Object);
			Assert.AreEqual(1+5, schemaStatements);
			sinkMock5.Verify(a => a.Add(new Statement(ns_foaf_name, NS.Rdfs.domainEntity, (Entity)ns_accounts)), Times.Exactly(1));
			sinkMock5.Verify(a => a.Add(new Statement(ns_age, NS.Rdfs.domainEntity, (Entity)ns_accounts)), Times.Exactly(1) );

			// test case: literal filter
			int litFilterStatements = 0;
			var sinkMock6 = GetSinkMock();
			sinkMock6.Setup(a => a.Add(It.IsAny<Statement>())).Callback(() => litFilterStatements++).Returns(true);
			store.Select(
				new SelectFilter(new[] { (Entity)ns_account3 }, null, null, null) 
					{ LiteralFilters = new [] { LiteralFilter.Create(LiteralFilter.CompType.GT, 20) } }, 
				sinkMock6.Object);
			Assert.AreEqual(2, litFilterStatements);
			sinkMock6.Verify(a => a.Add(new Statement( ns_account3 , ns_age, new Literal("52") )), Times.Exactly(1));
			sinkMock6.Verify(a => a.Add(new Statement(ns_account3, ns_number, new Literal("100"))), Times.Exactly(1));

		}




	}
}
