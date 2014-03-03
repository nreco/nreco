using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using NUnit.Framework;

namespace NReco.Tests {
	
	[TestFixture]
	public class DelegateAdapterTests {

		[Test]
		public void PartialDelegateAdapterTest() {
			Func<string, IDictionary<string, object>, object> f1 = (a1, a2) => {
				return a2[a1];
			};

			var c = new Dictionary<string, object>();
			c["var1"] = 1;
			c["var2"] = "bla";

			var f1var1 = (new PartialDelegateAdapter(f1, new[] { "var1" })).GetDelegate<Func<IDictionary<string,object>,object>>();
			Assert.AreEqual(1, f1var1(c));

			var f1var2 = (new PartialDelegateAdapter(f1, new[] { "var2" })).GetDelegate<Func<IDictionary<string, object>, object>>();
			Assert.AreEqual("bla", f1var2(c));

			var f1getvar = (new PartialDelegateAdapter(f1, new[] { NReco.PartialDelegateAdapter.KeepArg, c })).GetDelegate<Func<string, object>>();
			Assert.AreEqual(1, f1getvar("var1"));
			Assert.AreEqual("bla", f1getvar("var2"));

			Func<string, bool, object, object, string> f2 = (f, b, a1, a2) => {
				return String.Format(f, b, a1 ?? a2);
			};

			var f2true = (new PartialDelegateAdapter(f2, new[] { 
							"[{0}] {1}",
							true, 
							NReco.PartialDelegateAdapter.KeepArg, 
							"NULL" })).GetDelegate<Func<object, string>>();
			Assert.AreEqual("[True] NULL", f2true(null));
			Assert.AreEqual("[True] test", f2true("test"));

		}

		[Test]
		public void LazyDelegateAdapterTest() {
			var factoryCounter = 0;
			Func<Func<int, int>> delegFactory = () => {
				factoryCounter++;
				return (a) => a * 2;
			};

			var lazyDelegAdapter = new LazyDelegateAdapter(delegFactory);
			var lazyDeleg = lazyDelegAdapter.GetDelegate<Func<int, int>>();
			Assert.AreEqual(0, factoryCounter);

			Assert.AreEqual(10, lazyDeleg(5));
			Assert.AreEqual(1, factoryCounter);

		}

	}
}
