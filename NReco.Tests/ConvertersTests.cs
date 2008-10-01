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
		public void GenericTypeConverterTest() {
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

	}
}
