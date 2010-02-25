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
using System.Collections.Specialized;
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

		public Keyword[] GetTopKeywords(int maxResults) {
			return GetTopKeywords(null, maxResults);
		}

		public Keyword[] GetTopKeywords(string startsWith, int maxResults) {
			var indexRdr = Factory.CreateReader();
			var termEnum = indexRdr.Terms();

			var checkStartsWith = !String.IsNullOrEmpty(startsWith);
			var termsList = new List<Keyword>();
			while (termEnum.Next()) {
				var termText = termEnum.Term().Text();
				if (checkStartsWith && !termText.StartsWith(startsWith, StringComparison.CurrentCultureIgnoreCase))
					continue;
				var freq = termEnum.DocFreq();
				var minFreq = termsList.Count > 0 ? termsList[0].Freq : 0;
				if (freq>=minFreq || termsList.Count<maxResults) {
					var k = new Keyword { Text = termText, Freq = freq };
					int idx = 0;
					while (idx < termsList.Count && k.Freq > termsList[idx].Freq)
						idx++;
					termsList.Insert(idx, k);
					if (termsList.Count > maxResults)
						termsList.RemoveAt(0);
				}
			}
			indexRdr.Close();
			var res = termsList.ToArray();
			Array.Reverse(res);
			return res;
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
			searcher.Close();
			return docs;
		}

        public DocumentResult[] Search(string keywords) {
            return Search(keywords, Int32.MaxValue);
        }

        public DocumentResult[] Search(string keywords, int maxResults){
            return Search(keywords, DefaultSearchFields, maxResults);
        }

        public DocumentResult[] Search(string keywords, string[] fields, int maxResults) {
            var searcher = Factory.CreateSearcher();

            var queryString = QueryComposer.Provide(keywords);
            var parser = new MultiFieldQueryParser(fields, Factory.Analyzer);
            var hits = searcher.Search(parser.Parse(queryString));
            var docs = new DocumentResult[Math.Min(hits.Length(), maxResults)];
            for (int i = 0; i < docs.Length; i++)
                docs[i] = new DocumentResult(hits.Doc(i), hits.Score(i));
            searcher.Close();
            return docs;
        }

		public class Keyword {
			public string Text { get; set; }
			public int Freq { get; set; }
		}

	}

}
