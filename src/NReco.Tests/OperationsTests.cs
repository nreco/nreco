using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using NUnit.Framework;
using NReco;

using NReco.Providers;
using NReco.Collections;
using NReco.Operations;
using NReco.Converting;

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
			invMethod.TypeConverter = new GenericListConverter();
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

			evalCsCode.VarTypeConverter = new GenericListConverter();
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
		public void Chain() {
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


	}
}
