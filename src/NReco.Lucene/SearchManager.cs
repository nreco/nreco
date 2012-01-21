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
using NReco.Logging;
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
		static ILog log = LogManager.GetLogger(typeof(SearchManager));

		public IProvider<string, string> QueryComposer { get; set; }

		public ILuceneFactory Factory { get; set; }

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

		public Query ComposeQuery(string keywords) {
			return ComposeQuery(keywords, DefaultSearchFields);
		}

		public Query ComposeQuery(string keywords, string[] fields) {
			var queryString = QueryComposer.Provide(keywords);
			var parser = new MultiFieldQueryParser(fields, Factory.GetAnalyser() );
			return parser.Parse(queryString);
		}

		public Document[] SearchDocuments(string keywords, string[] fields, int maxResults) {
			var q = ComposeQuery(keywords, fields);
			return SearchDocuments(q, maxResults);
		}

		public Document[] SearchDocuments(Query q, int maxResults) {
			var searcher = Factory.CreateSearcher();
			log.Write(LogEvent.Debug, "SearchDocuments by query: {0}", q);
			var hits = searcher.Search(q);
			var docs = new Document[ Math.Min( hits.Length(), maxResults) ];
			for (int i = 0; i < docs.Length; i++)
				docs[i] = hits.Doc(i);
			searcher.Close();

			log.Write(LogEvent.Debug, "SearchDocuments results: {0} document(s)", docs.Length); 

			return docs;
		}

        public DocumentResult[] Search(string keywords) {
            return Search(keywords, Int32.MaxValue);
        }

        public DocumentResult[] Search(string keywords, int maxResults){
            return Search(keywords, DefaultSearchFields, maxResults);
        }

		public DocumentResult[] Search(string keywords, string[] fields, int maxResults) {
			var q = ComposeQuery(keywords, fields);
			return Search(q, maxResults);
		}

		public DocumentResult[] Search(Query q, int maxResults) {
            return Search(new SearchParams { Query = q, MaxResults = maxResults });
        }

        public DocumentResult[] Search(SearchParams s) {
            var searcher = Factory.CreateSearcher();
			log.Write(LogEvent.Debug, "Search query: {0}", s.Query); 
            var hits = s.Sort != null && s.Sort.Length > 0 ? searcher.Search(s.Query, new Sort(s.Sort)) : searcher.Search(s.Query);
            var docs = new DocumentResult[Math.Min(hits.Length(), s.MaxResults)];
            for (int i = 0; i < docs.Length; i++)
                docs[i] = new DocumentResult(hits.Doc(i), hits.Score(i));
            searcher.Close();
			log.Write(LogEvent.Debug, "Search results: {0} document(s)", docs.Length); 
            return docs;
        }

		public int SearchCount(SearchParams s) {
            var searcher = Factory.CreateSearcher();
			log.Write(LogEvent.Debug, "Search count query: {0}", s.Query);
			var hits = searcher.Search(s.Query);
			return hits.Length();
        }

		public class SearchParams {
			public Query Query { get; set; }
			public int MaxResults { get; set; }
			public string[] Sort { get; set; }
		}

		public class Keyword {
			public string Text { get; set; }
			public int Freq { get; set; }
		}

	}

}
