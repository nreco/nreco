using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using NReco;
using NUnit.Framework;

using NReco.Converters;
using NReco.Providers;
using NReco.Operations;

namespace NReco.Tests {

	[TestFixture]
	public class ConvertersTests {

		public void TypeConverterStaticMethodsTest() {
			ITypeConverter cnv = TypeConverter.FindConverter( typeof(Hashtable), typeof(IDictionary<string,object>));
			Assert.AreEqual(true, cnv!=null);
		}

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
			ConstProvider prv = new ConstProvider("aa");
			ConstProvider<string> strPrv = new ConstProvider<string>("zz");

			Assert.AreEqual(true, gPrvCnv.CanConvert(strPrv.GetType(), typeof(IProvider)));
			Assert.AreEqual(true, gPrvCnv.Convert(strPrv, typeof(IProvider)) is IProvider);
			Assert.AreEqual("zz", ((IProvider)gPrvCnv.Convert(strPrv, typeof(IProvider))).Provide(null)  );

			Assert.AreEqual(true, gPrvCnv.CanConvert(prv.GetType(), typeof(IProvider<string,string>)));
			Assert.AreEqual(true, gPrvCnv.Convert(prv, typeof(IProvider<string,string>)) is IProvider<string,string>);
			Assert.AreEqual("aa", ((IProvider<string,string>)gPrvCnv.Convert(prv, typeof(IProvider<string,string>))).Provide(null));

			// generic to generic
			Assert.AreEqual(true, gPrvCnv.CanConvert(typeof(IProvider<Context, NameValueContext>), typeof(IProvider<NameValueContext, Context>)));
			Assert.AreEqual(false, gPrvCnv.CanConvert(typeof(IProvider<Context, NameValueContext>), typeof(IProvider<object, Context>)));
			Assert.AreEqual(true, gPrvCnv.CanConvert(typeof(IProvider<Context, Context>), typeof(IProvider<Context, object>)));
			IProvider<Context, string> strByContextPrv = (IProvider<Context, string>)gPrvCnv.Convert(strPrv, typeof(IProvider<Context, string>));
			Assert.AreEqual("zz",strByContextPrv.Provide(Context.Empty) );

		}
		
		public void TestMethod(NameValueContext c) {
			c["a"] = "b";
		}

		public class TestGenOp : IOperation<NameValueContext> {
			public void Execute(NameValueContext c) {
				c["b"] = "a";
			}
		}

		public class NameValueExContext : NameValueContext { }
		
		[Test]
		public void GenericOperationConverterTest() {
			GenericOperationConverter gOpCnv = new GenericOperationConverter();
			NameValueContext c = new NameValueContext();
			InvokeMethod op = new InvokeMethod(this, "TestMethod", new object[] { c } );
			TestGenOp genOp = new TestGenOp();

			Assert.AreEqual(true, gOpCnv.CanConvert(genOp.GetType(), typeof(IOperation)));
			Assert.AreEqual(true, gOpCnv.Convert(genOp, typeof(IOperation)) is IOperation);
			((IOperation)gOpCnv.Convert(genOp, typeof(IOperation))).Execute(c);
			Assert.AreEqual("a", c["b"] );

			Assert.AreEqual(true, gOpCnv.CanConvert(op.GetType(), typeof(IOperation<NameValueContext>)));
			Assert.AreEqual(true, gOpCnv.Convert(op, typeof(IOperation<NameValueContext>)) is IOperation<NameValueContext>);
			((IOperation<NameValueContext>)gOpCnv.Convert(op, typeof(IOperation<NameValueContext>))).Execute(c);
			Assert.AreEqual("b", c["a"]);

			// compatible conversion between IOperation<>
			Assert.AreEqual(true, gOpCnv.CanConvert( typeof(IOperation<Context>), typeof(IOperation<NameValueContext>))) ;
			Assert.AreEqual(false, gOpCnv.CanConvert( typeof(IOperation<NameValueContext>), typeof(IOperation<Context>))) ;
			IOperation<NameValueExContext> genOpEx = (IOperation<NameValueExContext>) gOpCnv.Convert(genOp, typeof(IOperation<NameValueExContext>));
			NameValueExContext cEx = new NameValueExContext();
			genOpEx.Execute(cEx);
			Assert.AreEqual("a", cEx["b"]);


		}



	}
}
