using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using NUnit.Framework;

using NReco;
using NReco.Composition;
using NReco.Collections;
using NReco.Converting;
using Moq;

namespace NReco.Tests {

	[TestFixture]
	public class OperationsTests {

		[Test]
		public void InvokeMethod() {
			InvokeMethod invMethod = new InvokeMethod(this,"TestInvoke",
				 new object[]{
					new string[]{"aaa"},
					new int[] {1}
				 });
			Assert.AreEqual(true, invMethod.Provide(null));
		}

		public bool TestInvoke(string[] names, IList<int> rates) {
			Assert.AreEqual(1, names.Length);
			Assert.AreEqual(1, rates.Count);
			Assert.AreEqual(1, rates[0]);
			return true;
		}

		[Test]
		public void EvalCsCode() {
			EvalCsCode evalCsCode = new EvalCsCode();
			evalCsCode.Code = "result = str.Replace(\" \",\"_\")";
			evalCsCode.Variables = new EvalCsCode.VariableDescriptor[] {
				new EvalCsCode.VariableDescriptor("str", typeof(string), new ContextProvider())
			};
			Assert.AreEqual("x_x", evalCsCode.Provide("x x") );

			evalCsCode.Code = @"result = list.Contains(""x"")";
			evalCsCode.Variables = new EvalCsCode.VariableDescriptor[] {
				new EvalCsCode.VariableDescriptor("list", typeof(IList<string>), new ContextProvider())
			};
			Assert.AreEqual(true, evalCsCode.Provide( new string[] {"y", "x"} ));
			ArrayList aList = new ArrayList();
			aList.Add("a");
			Assert.AreEqual(false, evalCsCode.Provide(aList));

		}
		
		public class LogOperation : IOperation<object> {
			string logMsg;
			IList<string> log;
			public LogOperation(IList<string> log, string logMsg) {
				this.log = log;
				this.logMsg = logMsg;
			}

			public void Execute(object context) {
				log.Add(logMsg);
			}
		}

		[Test]
		public void ChainTest() {
			List<string> log = new List<string>();
			ChainOperationCall call1 = new ChainOperationCall(new LogOperation(log, "1"));
			ChainOperationCall call2 = new ChainOperationCall(new LogOperation(log, "2"));
			call2.RunCondition = new ConstProvider<IDictionary<string,object>,bool>(false);

			Chain c = new Chain( new IOperation<IDictionary<string,object>>[] { call1, call2 } );
			NameValueContext context = new NameValueContext();
			c.Execute(context);
			Assert.AreEqual(1, log.Count);
			Assert.AreEqual("1", log[0] );

		}

		[Test]
		public void EachTest() {
			var each = new Each<string>();
			
			var itemsMoq = new Mock<IProvider<string, IEnumerable>>();
			var arr = new[]{ "a", "b", "c" };
			itemsMoq.Setup(fn => fn.Provide("aa")).Returns(arr);
			
			var opMoq = new Mock<IOperation<EachContext<string>>>();
			var idx = 0;
			opMoq.Setup(fn => fn.Execute(It.Is<EachContext<string>>(i => i.Item.ToString()== arr[idx])))
				.Callback(() => idx++);
			each.ItemsProvider = itemsMoq.Object;
			each.ItemOperation = opMoq.Object;
			each.Execute("aa");

			
		}


	}
}
