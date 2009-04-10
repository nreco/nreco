using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using System.Data;

using NUnit.Framework;
using NReco;
using NReco.Composition;
using NReco.Collections;

namespace NReco.Tests {

	[TestFixture]
	public class CollectionsTests {

		[Test]
		public void DictionaryWrapperTest() {
			IDictionary<string,int> genericDict = new Dictionary<string,int>();
			genericDict.Add("aa", 1);
			IDictionary dictionary = new DictionaryWrapper<string,int>(genericDict);
			dictionary.Add("bb", 2);

			Assert.AreEqual( 1, dictionary["aa"]);
			Assert.AreEqual(2, dictionary["bb"]);
			
			dictionary.Remove("aa");
			Assert.AreEqual(false, dictionary.Contains("aa"));

			foreach (DictionaryEntry entry in dictionary) {
				Assert.AreEqual(2, entry.Value);
				Assert.AreEqual("bb", entry.Key);
			}
		}

		[Test]
		public void ObjectDictionaryTest() {
			var o = new { A = "a", B = "b" };
			var objD = new ObjectDictionaryWrapper(o);
			Assert.AreEqual(objD["A"].ToString(), "a");
			Assert.IsTrue(objD.ContainsKey("B"));
			Assert.AreEqual(2, objD.Count);
		}

		[Test]
		public void DataRowDictionaryTest() {
			DataSet ds = new DataSet();
			var tbl = ds.Tables.Add("test");
			tbl.Columns.Add("A", typeof(string));
			tbl.Columns.Add("B", typeof(string));
			var r = tbl.NewRow();
			r["A"] = "a";
			r["B"] = "b";
			tbl.Rows.Add(r);

			var dataRowD = new DataRowDictionaryWrapper(r);
			Assert.AreEqual(dataRowD["A"].ToString(), "a");
			Assert.IsTrue(dataRowD.ContainsKey("B"));
			Assert.AreEqual(2, dataRowD.Count);
		}


	}
}
