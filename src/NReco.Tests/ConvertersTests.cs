using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using NReco;
using NUnit.Framework;
using System.ComponentModel;
using System.Globalization;

using NReco.Converting;
using NReco.Composition;
using NReco.Composition;
using NReco.Winter.Converting;

namespace NReco.Tests {

	[TestFixture]
	public class ConvertersTests {

		public void TypeConverterStaticMethodsTest() {
			ITypeConverter cnv = ConvertManager.FindConverter( typeof(Hashtable), typeof(IDictionary<string,object>));
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
			ProviderConverter gPrvCnv = new ProviderConverter();
			ConstProvider prv = new ConstProvider("aa");
			ConstProvider<Object,string> strPrv = new ConstProvider<object,string>("zz");

			Assert.AreEqual(true, gPrvCnv.CanConvert(strPrv.GetType(), typeof(IProvider<object,object>)));
			Assert.AreEqual(true, gPrvCnv.Convert(strPrv, typeof(IProvider<object,object>)) is IProvider<object,object>);
			Assert.AreEqual("zz", ((IProvider<object,object>)gPrvCnv.Convert(strPrv, typeof(IProvider<object,object>))).Provide(null)  );

			Assert.AreEqual(true, gPrvCnv.CanConvert(prv.GetType(), typeof(IProvider<string,string>)));
			Assert.AreEqual(true, gPrvCnv.Convert(prv, typeof(IProvider<string,string>)) is IProvider<string,string>);
			Assert.AreEqual("aa", ((IProvider<string,string>)gPrvCnv.Convert(prv, typeof(IProvider<string,string>))).Provide(null));

			// generic to generic
			Assert.AreEqual(true, gPrvCnv.CanConvert(typeof(IProvider<Context, NameValueContext>), typeof(IProvider<NameValueContext, Context>)));
			Assert.AreEqual(true, gPrvCnv.CanConvert(typeof(IProvider<Context, NameValueContext>), typeof(IProvider<object, Context>)));
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
			OperationConverter gOpCnv = new OperationConverter();
			NameValueContext c = new NameValueContext();
			InvokeMethod op = new InvokeMethod(this, "TestMethod", new object[] { c } );
			TestGenOp genOp = new TestGenOp();

			Assert.AreEqual(true, gOpCnv.CanConvert(genOp.GetType(), typeof(IOperation<object>)));
			Convert.ToString( gOpCnv.Convert(genOp, typeof(IOperation<object>) ).GetType() );
			Assert.AreEqual(true, gOpCnv.Convert(genOp, typeof(IOperation<object>)) is IOperation<object>);
			((IOperation<object>)gOpCnv.Convert(genOp, typeof(IOperation<object>))).Execute(c);
			Assert.AreEqual("a", c["b"] );

			Assert.AreEqual(true, gOpCnv.CanConvert(op.GetType(), typeof(IOperation<NameValueContext>)));
			Assert.AreEqual(true, gOpCnv.Convert(op, typeof(IOperation<NameValueContext>)) is IOperation<NameValueContext>);
			((IOperation<NameValueContext>)gOpCnv.Convert(op, typeof(IOperation<NameValueContext>))).Execute(c);
			Assert.AreEqual("b", c["a"]);

			// compatible conversion between IOperation<>
			Assert.AreEqual(true, gOpCnv.CanConvert( typeof(IOperation<Context>), typeof(IOperation<NameValueContext>))) ;
			Assert.AreEqual(true, gOpCnv.CanConvert( typeof(IOperation<NameValueContext>), typeof(IOperation<Context>))) ;
			IOperation<NameValueExContext> genOpEx = (IOperation<NameValueExContext>) gOpCnv.Convert(genOp, typeof(IOperation<NameValueExContext>));
			NameValueExContext cEx = new NameValueExContext();
			genOpEx.Execute(cEx);
			Assert.AreEqual("a", cEx["b"]);


		}


		[Test]
		public void NiProviderConverterTest() {
			NiProviderConverter conv = new NiProviderConverter();
			NI.Common.Providers.ConstObjectProvider niPrv = new NI.Common.Providers.ConstObjectProvider("aa");
			ConstProvider prv = new ConstProvider("zz");

			Assert.AreEqual(true, conv.CanConvert(niPrv.GetType(), typeof(IProvider<object,object>)));
			Assert.AreEqual(true, conv.CanConvert(niPrv.GetType(), typeof(IProvider<object,string>)));
			Assert.AreEqual(true, conv.Convert(prv, typeof(NI.Common.Providers.IObjectProvider)) is NI.Common.Providers.IObjectProvider);
			Assert.AreEqual("aa", ((IProvider<object,object>)conv.Convert(niPrv, typeof(IProvider<object,object>))).Provide(null));
			Assert.AreEqual("aa", ((IProvider<object,string>)conv.Convert(niPrv, typeof(IProvider<object,string>))).Provide(null));
			Assert.AreEqual("zz", ((NI.Common.Providers.IObjectProvider)conv.Convert(prv, typeof(NI.Common.Providers.IObjectProvider))).GetObject(null));


		}

		[Test]
		public void ContextConverterTest() {
			ContextConverter conv = new ContextConverter();
			var eachCntx = new EachContext<string>();
			eachCntx.Index = 1;
			eachCntx.Item = "a";
			Assert.IsTrue(conv.CanConvert(eachCntx.GetType(), typeof(IDictionary)));
			Assert.IsTrue(conv.CanConvert(eachCntx.GetType(), typeof(IDictionary<string,object>)));
			Assert.IsFalse(conv.CanConvert(eachCntx.GetType(), typeof(IDictionary<string, string>)));
			
			var dictCntx = (IDictionary)conv.Convert(eachCntx, typeof(IDictionary));
			Assert.AreEqual(1, dictCntx["Index"]);

			var gDictCntx = (IDictionary<string, object>)conv.Convert(eachCntx, typeof(IDictionary<string, object>));
			Assert.AreEqual("a", dictCntx["Item"]);

		}

		[Test]
		public void DelegateConverterTest() {
			var dConv = new DelegateConverter();

			Assert.IsTrue( dConv.CanConvert(typeof(Func<object>), typeof(ICloneable)) );
			Assert.IsTrue(dConv.CanConvert(typeof(ICloneable), typeof(Func<object>)));

			Assert.IsTrue(dConv.CanConvert(typeof(EventHandler), typeof(Action<object,EventArgs>)));

			Func<object, bool> t1 = (b) => { return b!=null; };

			var customDelegate1 = (CustomDelegateType) dConv.Convert(t1, typeof(CustomDelegateType));
			Assert.IsTrue(customDelegate1("somestr"));

			Func<object, object> t2 = (b) => { return b != null; };
			var customDelegate2 = (CustomDelegateType)dConv.Convert(t2, typeof(CustomDelegateType));
			Assert.IsTrue(customDelegate1("somestr"));

			/*var stopWatch1 = new System.Diagnostics.Stopwatch();
			stopWatch1.Start();
			for (int i = 0; i < 100000; i++) {
				customDelegate1("somestr");
			}
			stopWatch1.Stop();
			Console.WriteLine("Deleg -> Deleg: {0}", stopWatch1.Elapsed.ToString());*/


			Func<Hashtable> t3 = () => { return new Hashtable() { {"a",1} }; };
			var t3gen = (Func<IDictionary<string, object>>)dConv.Convert(t3, typeof(Func<IDictionary<string, object>>));
			Assert.AreEqual(1, t3gen()["a"]);

			// test explicit converter to interface
			string doSomethingRes = null;
			// from delegate
			Action<object, int> doSomething = (o, i) => {
				doSomethingRes = String.Format("{0}_{1}", o, i);
			};
			var doSomethingInterface = dConv.Convert(doSomething, typeof(InterfaceWithConv)) as InterfaceWithConv;
			doSomethingInterface.DoSomething("a", 1);
			Assert.AreEqual("a_1", doSomethingRes);
			Assert.IsTrue(doSomethingInterface is InterfaceConv.Proxy);

			/*var stopWatch2 = new System.Diagnostics.Stopwatch();
			stopWatch2.Start();
			for (int i = 0; i < 100000; i++) {
				doSomethingInterface.DoSomething("a", 1);
			}
			stopWatch2.Stop();
			Console.WriteLine("Deleg -> SAM (Custom TypeConverter proxy): {0}", stopWatch2.Elapsed.ToString());*/


			// from another interface
			var doSomethingImpl = new CompatibleInterfaceImpl();
			doSomethingInterface = dConv.Convert(doSomethingImpl, typeof(InterfaceWithConv)) as InterfaceWithConv;
			doSomethingInterface.DoSomething("b", 2);
			Assert.AreEqual("b_2", doSomethingImpl.Res);


			// from delegate to interface using realproxy
			Func<object, int, int> doSomething2 = (o, i) => {
				return String.Format("{0}_{1}", o, i).Length;
			};
			var doSomethingInterface2 = dConv.Convert(doSomething2, typeof(CompatibleInterface)) as CompatibleInterface;
			Assert.AreEqual(5, doSomethingInterface2.Update("zz", "10") );
			
			// from SAM to SAM using realproxy
			var doSomethingInterface3 = dConv.Convert(doSomethingImpl, typeof(CompatibleInterface2)) as CompatibleInterface2;
			Assert.AreEqual(6, doSomethingInterface3.GetLen(1, "test"));

			// extra check - for result contravariance
			Func<string,object,string> updateStr = (s,o) => { return s.Length.ToString(); }; 
			var doSomethingInterface4 = dConv.Convert(updateStr, typeof(CompatibleInterface)) as CompatibleInterface;
			Assert.AreEqual(3, doSomethingInterface4.Update("abc", null) );

			/*var stopWatch3 = new System.Diagnostics.Stopwatch();
			stopWatch3.Start();
			for (int i = 0; i < 100000; i++) {
				doSomethingInterface3.GetLen(1, "test");
			}
			stopWatch3.Stop();
			Console.WriteLine("SAM -> SAM (RealProxy): {0}", stopWatch3.Elapsed.ToString());*/
		}

		public delegate bool CustomDelegateType(string param);

		[TypeConverter(typeof(InterfaceConv))]
		public interface InterfaceWithConv {
			void DoSomething(string a, int b);
		}
		public interface CompatibleInterface {
			int Update(string a, object b);
		}
		public interface CompatibleInterface2 {
			object GetLen(int a, string b);
		}

		public class CompatibleInterfaceImpl : CompatibleInterface {
			public string Res;
			public int Update(string a, object b) {
				Res = String.Format("{0}_{1}", a, b);
				return Res.Length;
			}
		}

		public class InterfaceConv : TypeConverter {
			public override bool CanConvertFrom(ITypeDescriptorContext context, Type sourceType) {
				if (TypeHelper.IsDelegate(sourceType))
					return true;
				return base.CanConvertFrom(context, sourceType);
			}
			public override object ConvertFrom(ITypeDescriptorContext context, CultureInfo culture, object value) {
				if (value is Delegate)
					return new Proxy((Delegate)value);
				return base.ConvertFrom(context, culture, value);
			}

			public class Proxy : InterfaceWithConv {
				Delegate D;
				public Proxy(Delegate d) {
					D = d;
				}
				public void DoSomething(string a, int b) {
					D.DynamicInvoke(a, b);
				}
			}
		}


	}
}
