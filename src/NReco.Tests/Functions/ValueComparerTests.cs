using System;
using System.Collections.Generic;
using System.Collections;
using System.Diagnostics;
using System.Text;
using NUnit.Framework;
using NReco;
using NReco.Statements;

namespace NReco.Tests.Functions {

	[TestFixture]
	public class ValueComparerTests {

		[Test]
		public void Compare() {
			Assert.AreEqual(0, ValueComparer.Instance.Compare(true, true));
			Assert.AreEqual(0, ValueComparer.Instance.Compare(true, "true"));
			Assert.AreEqual(1, ValueComparer.Instance.Compare(true, false));

			Assert.AreEqual(0, ValueComparer.Instance.Compare(1, "1"));
			Assert.AreEqual(-1, ValueComparer.Instance.Compare(1, 2));

			Assert.AreEqual(1, ValueComparer.Instance.Compare("3", 1));

			Assert.AreEqual(0, ValueComparer.Instance.Compare( new TimeSpan(0,0,1), "0:0:1"));

			Assert.AreEqual(0, ValueComparer.Instance.Compare("abc", new StringBuilder("abc") ));

			Assert.AreEqual(0, ValueComparer.Instance.Compare(new int[]{1,2,3}, new decimal[] {1,2,3 }));

			Assert.AreEqual(-1, ValueComparer.Instance.Compare(new int[] { 1, 2, 3 }, new decimal[] { 1, 2, 4 }));
		}

		[Test]
		[ExpectedException(typeof(InvalidCastException))]
		public void CompareIncompatibleType() {
			ValueComparer.Instance.Compare( DateTime.Now, TimeSpan.Zero);
		}


	}
}
