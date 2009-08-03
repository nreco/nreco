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
	/// Facade for Lucene search capabilities.
	/// </summary>
	public class SearchManager {

		public IProvider<string, string> QueryComposer { get; set; }

		public LuceneFactory Factory { get; set; }

		public string[] DefaultSearchFields { get; set; }

		public SearchManager() {
			QueryComposer = new QueryStringComposer();
		}

		public Document[] SearchDocuments(string keywords) {
			return SearchDocuments(keywords, Int32.MaxValue);
		}
		
		public Document[] SearchDocuments(string keywords, int maxResults) {
			return SearchDocuments(keywords, DefaultSearchFields, maxResults);
		}


		public Document[] SearchDocuments(string keywords, string[] fields, int maxResults) {
			var searcher = Factory.CreateSearcher();

			var queryString = QueryComposer.Provide(keywords);
			var parser = new MultiFieldQueryParser(fields, Factory.Analyzer);
			var hits = searcher.Search(parser.Parse(queryString));
			var docs = new Document[ Math.Min( hits.Length(), maxResults) ];
			for (int i = 0; i < docs.Length; i++)
				docs[i] = hits.Doc(i);
			return docs;
		}


	}

}
