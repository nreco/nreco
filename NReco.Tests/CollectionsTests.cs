using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using NUnit.Framework;
using NReco;
using NReco.Providers;
using NReco.Collections;

namespace NReco.Tests {

	[TestFixture]
	public class CollectionsTests {

		[Test]
		public void DictionaryWrapper() {
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

	}
}
