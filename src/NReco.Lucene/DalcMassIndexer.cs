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
using System.Data;
using System.Collections.Generic;
using System.Text;

using NI.Data.Dalc;

namespace NReco.Lucene {
	
	/// <summary>
	/// Mass indexing operation for data from DALC source.
	/// </summary>
	public class DalcMassIndexer : IOperation<object> {

		public IDalc Dalc { get; set; }

		public string SourceName { get; set; }

		public DataRowIndexer Indexer { get; set; }

		public int BatchSize { get; set; }

		public TransactionManager Transaction { get; set; }

		public DalcMassIndexer() {
			BatchSize = 100;
		}

		public void Run() {
			var ds = new DataSet();
			Query batchQ = new Query(SourceName);
			batchQ.RecordCount = BatchSize;
			
			do {
				if (ds.Tables.Contains(SourceName))
					ds.Tables[SourceName].Clear();
				Dalc.Load(ds, batchQ);

				if (Transaction!=null)
					Transaction.Begin();

				foreach (DataRow r in ds.Tables[SourceName].Rows)
					Indexer.Add(r);

				if (Transaction!=null)
					Transaction.Commit();

				// next batch
				batchQ.StartRecord += BatchSize;
			} while (ds.Tables[SourceName].Rows.Count >= BatchSize);
		}


		void IOperation<object>.Execute(object context) {
			Run();
		}

	}

}
