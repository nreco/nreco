#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2012 Vitaliy Fedorchenko
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
using System.IO;
using System.Web;

using NReco;
using Lucene.Net;
using Lucene.Net.Index;
using Lucene.Net.Search;
using Lucene.Net.Analysis;
using Lucene.Net.Analysis.Standard;
using Lucene.Net.Documents;
using Lucene.Net.QueryParsers;

using Lucene.Net.Store;

using LuceneDirectory = Lucene.Net.Store.Directory;

namespace NReco.Lucene {
	
	/// <summary>
	/// Lucene index central objects (searcher, index writer, etc) factory
	/// </summary>
	public class DirectoryLuceneFactory : ILuceneFactory {

		public Analyzer Analyzer { get; set; }

		public bool UseCompoundFile { get; set; }

		public LuceneDirectory StoreDirectory { get; set; }

		public Transaction Transaction { get; set; }

		public DirectoryLuceneFactory() {
			Analyzer = new StandardAnalyzer();
			UseCompoundFile = true;
		}

		public void Clear() {
			foreach (var fileName in StoreDirectory.ListAll()) {
				StoreDirectory.DeleteFile(fileName);
			}
		}
		
		public Analyzer GetAnalyser() {
			return Analyzer;
		}
		
		public IndexWriter CreateWriter() {
			var storeDirectoryKey = String.Format("{0}#{1}", StoreDirectory.GetHashCode(), StoreDirectory.ToString() );

			if (Transaction != null && Transaction.IsInTransaction && Transaction.GetTransactWriter(storeDirectoryKey) != null)
				return Transaction.GetTransactWriter(storeDirectoryKey);

			var indexExists = IndexReader.IndexExists(StoreDirectory);
			var indexWriter = new TransactIndexWriter(StoreDirectory, Analyzer, !indexExists, IndexWriter.MaxFieldLength.UNLIMITED);
			indexWriter.SetUseCompoundFile(UseCompoundFile);

			if (Transaction != null) {
				Transaction.RegisterTransactWriter(storeDirectoryKey, indexWriter);
			}

			return indexWriter;
		}

		public IndexSearcher CreateSearcher() {
			if (StoreDirectory.ListAll().Length==0) {
				var indexWr = CreateWriter();
				indexWr.Close();
			}
			return new IndexSearcher(StoreDirectory, true);
		}

		public IndexReader CreateReader() {
			return IndexReader.Open(StoreDirectory, true);
		}
	
	}
}
