using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NReco.Converting;

using NUnit.Framework;
using NReco.Statements;

namespace NReco.Tests.Statements {
	
	[TestFixture]
	public class StatementDelegateTests {

		[Test]
		public void InvokeFunc() {
			var stDeleg0 = new StatementDelegateAdapter( StatementTests.ComposeCombinedStatement(), new string[0], "sum");

			var getSum = stDeleg0.GetDelegate<Func<double>>();
			Assert.AreEqual(33, getSum());

			var stDeleg1 = new StatementDelegateAdapter(StatementTests.ComposeCombinedStatement(), new string[] { "sum"}, "sum");
			var getSum1 = stDeleg1.GetDelegate<Func<double, double>>();

			Assert.AreEqual(23, getSum1(-10));
		}

	
	}
}
