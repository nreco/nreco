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
	
	/// <summary>
	/// Represents Lucene transaction for index writers (used by LuceneFactory).
	/// </summary>
	public class Transaction {

		private IDictionary<string, TransactIndexWriter> Writers = new Dictionary<string, TransactIndexWriter>();
		
		public bool IsInTransaction { get; internal set; }

		public Transaction() {
			IsInTransaction = true;
		}

		public TransactIndexWriter GetTransactWriter(string key) {
			return Writers.ContainsKey(key) ? Writers[key] : null;
		}
		
		public void RegisterTransactWriter(string key, TransactIndexWriter wr) {
			if (IsInTransaction) {
				Writers[key] = wr;
				wr.Transaction = this;
			}
		}
		
		public void Commit() {
			if (IsInTransaction) {
				foreach (var entry in Writers) {
					if (entry.Value.Transaction==this) {
						entry.Value.Transaction = null;
						entry.Value.Close();
					}
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
