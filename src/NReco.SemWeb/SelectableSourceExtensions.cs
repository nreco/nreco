#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008,2009 Vitaliy Fedorchenko
 * Distributed under the LGPL licence
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#endregion

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SemWeb;

namespace NReco.SemWeb {
	
	public static class SelectableSourceExtensions {
		
		public static Statement? SelectSingle(this SelectableSource src, Statement tpl) {
			var sink = new FirstStatementSink();
			src.Select(tpl, sink);
			return sink.First;
		}

		public static Statement? SelectSingle(this SelectableSource src, SelectFilter filter) {
			var sink = new FirstStatementSink();
			src.Select(filter, sink);
			return sink.First;
		}

		public static Literal SelectLiteral(this SelectableSource src, Statement tpl) {
			var st = SelectSingle(src, tpl);
			if (st.HasValue && st.Value.Object is Literal)
				return (Literal)st.Value.Object;
			return null;
		}

		public static IList<Statement> SelectAll(this SelectableSource src, Statement tpl) {
			var sink = new AllStatementSink(false);
			src.Select(tpl, sink);
			return sink.List;
		}

		internal class AllStatementSink : StatementSink {
			public IList<Statement> List { get; private set; }
			bool Distinct;

			public AllStatementSink(bool distinct) {
				List = new List<Statement>();
				Distinct = distinct;
			}

			public bool Add(Statement st) {
				if (!Distinct || !List.Contains(st))
					List.Add(st);
				return true;
			}

		}

		internal class FirstStatementSink : StatementSink {
			public Statement? First { get; private set; }

			public FirstStatementSink() {
				First = null;
			}

			public bool Add(Statement st) {
				if (!First.HasValue) {
					First = st;
					return true;
				} else
					return false;
			}
		}

	}


}
