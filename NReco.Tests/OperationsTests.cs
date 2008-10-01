using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;
using NReco;

using NReco.Providers;
using NReco.Collections;
using NReco.Operations;
using NReco.Converters;

namespace NReco.Tests {

	[TestFixture]
	public class OperationsTests {

		[Test]
		public void MethodInvoke() {
			 
			InvokeMethod invMethod = new InvokeMethod(this,"TestInvoke",
				 new object[]{
					new string[]{"aaa"},
					new int[] {1}
				 });
			invMethod.TypeConverter = new GenericListConverter();
			Assert.AreEqual(true, invMethod.Get(null));
		}

		public bool TestInvoke(string[] names, IList<int> rates) {
			Assert.AreEqual(1, names.Length);
			Assert.AreEqual(1, rates.Count);
			Assert.AreEqual(1, rates[0]);
			return true;
		}

		

	}
}
