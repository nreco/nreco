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

namespace NReco.Lucene {
	
	/// <summary>
	/// Lucene index central objects (searcher, index writer, etc) factory
	/// </summary>
	public class LuceneFactory : ILuceneFactory {

		public Analyzer Analyzer { get; set; }

		public bool UseCompoundFile { get; set; }

		public string IndexDir { get; set; }

		public Transaction Transaction { get; set; }


		public LuceneFactory() {
			Analyzer = new StandardAnalyzer();
			UseCompoundFile = true;
		}

		public void Clear() {
			var indexDir = ResolveLocalIndexPath();
			if (Directory.Exists(indexDir)) {
				Directory.Delete(indexDir,true);
			}
		}
		
		public Analyzer GetAnalyser() {
			return Analyzer;
		}
		
		public IndexWriter CreateWriter() {
			var indexDir = ResolveLocalIndexPath();
			if (Transaction != null && Transaction.IsInTransaction && Transaction.GetTransactWriter(indexDir)!=null)
				return Transaction.GetTransactWriter(indexDir);

			var indexExists = IndexReader.IndexExists(indexDir);
			var indexWriter = new TransactIndexWriter(ResolveLocalIndexPath(), Analyzer, !indexExists, IndexWriter.MaxFieldLength.UNLIMITED);
			indexWriter.SetUseCompoundFile(UseCompoundFile);

			if (Transaction != null) {
				Transaction.RegisterTransactWriter(indexDir, indexWriter);
			}

			return indexWriter;
		}

		public IndexSearcher CreateSearcher() {
			var indexDir = ResolveLocalIndexPath();
			if (!Directory.Exists(indexDir)) {
				var indexWr = CreateWriter();
				indexWr.Close();
			}
			return new IndexSearcher(indexDir);
		}

		public IndexReader CreateReader() {
			var indexDir = ResolveLocalIndexPath();
			return IndexReader.Open( indexDir );
		}

		protected string ResolveLocalIndexPath() {
			if (!Path.IsPathRooted(IndexDir)) {
				return Path.Combine(HttpContext.Current != null ? HttpRuntime.AppDomainAppPath : AppDomain.CurrentDomain.BaseDirectory, IndexDir);
			}
			return IndexDir;
		}
	
	}
}
