using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NReco.Converting;

using NUnit.Framework;
using NReco.Dsm.Composition;

namespace NReco.Tests.Composition {
	
	[TestFixture]
	public class StatementTests {

		public static IStatement ComposeCombinedStatement() {
			var set1 = new SetSt( "sum", 0 );
			var if1 = new If( (cntx) => {
				return !cntx.ContainsKey("sum");
			}, set1);

			var set2 = new SetSt( "items", new double[] { 1,1,2,3,5,8,13 } );
			var sumSt = new DelegateInvoke( 
					(Func<double,double,double>) ( (sum,a) => { return sum+a; } ),
					new Func<IDictionary<string,object>,object>[] {
						(cntx) => { return cntx["sum"]; },
						(cntx) => { return cntx["itm"]; }
					},
					"sum"
				);
			var each1 = new Each((cntx) => { return cntx["items"] as IEnumerable; }, sumSt, "itm");
			var sq1 = new Sequence( new IStatement[] {
				if1, set2, each1
			});

			return sq1;
		}

		[Test]
		public void If() {
			var ifSt = new If((cntx) => cntx.ContainsKey("a"),
				new SetSt("b", 1), new SetSt("b", 2));

			var c = new Dictionary<string, object>();
			ifSt.Execute(c);
			Assert.AreEqual(2, c["b"]);
			c["a"] = true;

			ifSt.Execute(c);
			Assert.AreEqual(1, c["b"]);
		}

		[Test]
		public void Each() {
			var c = new Dictionary<string, object>();
			c["items"] = new int[] { 1, 5, 10, 15 };

			var processedItems = new List<int>();
			var itemSt = ConvertManager.ChangeType<IStatement>( (Action<IDictionary<string,object>>) ((cntx) => {
				processedItems.Add( (int)cntx["itm"] );
			}));
			var eachSt = new Each((cntx) => { return cntx["items"] as IEnumerable; }, itemSt, "itm");
			eachSt.Execute(c);

			Assert.AreEqual(0, ValueComparer.Instance.Compare(c["items"], processedItems) );
		}

		[Test]
		public void Sequence() {
			var c = new Dictionary<string, object>();

			var sqSt = new Sequence(new[] {
				new SetSt("a", 1),
				new SetSt("b", 2),
				new SetSt("c", 3)
			});
			sqSt.Execute(c);

			Assert.AreEqual(3, c.Count);
			Assert.AreEqual(1, c["a"]);
		}

		[Test]
		public void DelegateInvoke() {
			var c = new Dictionary<string, object>();

			Func<string,int,string> testDeleg = (a1,a2) => {
				return String.Format(a1,a2);
			};
			var invDelegSt = new DelegateInvoke(testDeleg, new[] {
				(Func<IDictionary<string,object>,object>) ((cntx) => { return "-{0}-"; }),
				(Func<IDictionary<string,object>,object>) ((cntx) => { return "5"; }) // should be converted to int
			}, "test");
			invDelegSt.Execute(c);

			Assert.AreEqual("-5-", c["test"] );
		}

		[Test]
		public void ThreadImpersonate() {
			var impersonatedIdentityName = String.Empty;
			IStatement impersonatedSt = ConvertManager.ChangeType<IStatement>( 
					(Action<IDictionary<string,object>>) ((c) => {
						impersonatedIdentityName = System.Threading.Thread.CurrentPrincipal.Identity.Name;
					})
				);
			var imp = new ThreadImpersonate((c) => {
				return new System.Security.Principal.GenericPrincipal(
					new System.Security.Principal.GenericIdentity("test"), new string[0]);
			}, impersonatedSt);
			imp.Execute(new Dictionary<string, object>());

			Assert.AreEqual("test", impersonatedIdentityName);
		}

		[Test]
		public void Throw() {
			var throwSt = new Throw((c) => {
				throw new ArgumentException();
			});

			Assert.Throws<ArgumentException>(() => {
				throwSt.Execute(new Dictionary<string, object>());
			});
		}


		public class SetSt : IStatement {

			string Key;
			object Val;
			public int CallCounter = 0;

			public SetSt(string key, object val) {
				Key = key;
				Val = val;
			}

			public void Execute(IDictionary<string, object> context) {
				context[Key] = Val;
				CallCounter++;
			}
		}
	}
}
