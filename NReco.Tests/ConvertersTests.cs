using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using NReco;
using NUnit.Framework;

using NReco.Converters;

namespace NReco.Tests {

	[TestFixture]
	public class ConvertersTests {

		[Test]
		public void GenericListConverterTest() {
			List<string> l = new List<string>();
			GenericListConverter gListCnv = new GenericListConverter();
			l.Add("a");
			Assert.AreEqual(true, gListCnv.CanConvert(l.GetType(), typeof(IList)));
			Assert.AreEqual(true, gListCnv.Convert(l, typeof(IList)) is IList);
			Assert.AreEqual("a", ((IList)gListCnv.Convert(l, typeof(IList)))[0]);

			ArrayList nonGList = new ArrayList();
			nonGList.Add("a");
			Assert.AreEqual(true, gListCnv.CanConvert(nonGList.GetType(), typeof(IList<string>)));
			Assert.AreEqual(true, gListCnv.Convert(nonGList, typeof(IList<string>)) is IList<string>);
			Assert.AreEqual("a", ((IList<string>)gListCnv.Convert(nonGList, typeof(IList<string>)))[0] );

		}

		[Test]
		public void GenericCollectionConverterTest() {
			GenericCollectionConverter gCollCnv = new GenericCollectionConverter();
			List<string> genList = new List<string>();
			genList.Add("z");
			Assert.AreEqual(true, gCollCnv.CanConvert(genList.GetType(), typeof(ICollection)));
			Assert.AreEqual(true, gCollCnv.Convert(genList, typeof(ICollection)) is ICollection);
			Assert.AreEqual(1, ((ICollection)gCollCnv.Convert(genList, typeof(ICollection))).Count);

			ArrayList nonGColl = new ArrayList();
			nonGColl.Add("z");
			Assert.AreEqual(true, gCollCnv.CanConvert(nonGColl.GetType(), typeof(ICollection<string>)));
			Assert.AreEqual(true, gCollCnv.Convert(nonGColl, typeof(ICollection<string>)) is ICollection<string>);
		}

		[Test]
		public void GenericDictionaryConverterTest() {
			GenericDictionaryConverter gDictCnv = new GenericDictionaryConverter();
			Dictionary<string,object> genDict = new Dictionary<string,object>();
			genDict["k1"] = "ddd";
			genDict["k2"] = 2;

			Assert.AreEqual(true, gDictCnv.CanConvert(genDict.GetType(), typeof(IDictionary)));
			Assert.AreEqual(true, gDictCnv.Convert(genDict, typeof(IDictionary)) is IDictionary);
			IDictionary convertedDict = (IDictionary)gDictCnv.Convert(genDict, typeof(IDictionary));
			Assert.AreEqual("ddd", convertedDict["k1"]);
			Assert.AreEqual(2, convertedDict["k2"]);

			Hashtable nonGDict = new Hashtable();
			nonGDict["z"] = "A";
			Assert.AreEqual(true, gDictCnv.CanConvert(nonGDict.GetType(), typeof(IDictionary<string,string>)));
			Assert.AreEqual(true, gDictCnv.Convert(nonGDict, typeof(IDictionary<string, string>)) is IDictionary<string,string>);
			Assert.AreEqual("A", ( (IDictionary<string,string>) gDictCnv.Convert(nonGDict, typeof(IDictionary<string, string>)))["z"] );
		}

		[Test]
		public void GenericProviderConverterTest() {
			GenericProviderConverter gPrvCnv = new GenericProviderConverter();

		}


	}
}
