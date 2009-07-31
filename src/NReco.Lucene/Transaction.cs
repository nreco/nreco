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

using Lucene.Net;
using Lucene.Net.Index;
using Lucene.Net.Search;

namespace NReco.Lucene {
	
	public class Transaction {

		internal IDictionary<string, TransactIndexWriter> Writers = new Dictionary<string, TransactIndexWriter>();
		internal bool IsInTransaction;

		public Transaction() {
			IsInTransaction = true;
		}

		public void Commit() {
			foreach (var entry in Writers) {
				if (entry.Value.IsInTransaction) {
					entry.Value.IsInTransaction = false;
					entry.Value.Close();
				}
			}
			IsInTransaction = false;
			Writers.Clear();
		}

		public void Rollback() {
			foreach (var entry in Writers)
				entry.Value.Rollback();
			IsInTransaction = false;
			Writers.Clear();
		}

	}

}
