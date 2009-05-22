using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;

using NReco;
using NReco.Web;

using Lucene.Net;
using Lucene.Net.Analysis;
using Lucene.Net.Analysis.Standard;
using Lucene.Net.Documents;
using Lucene.Net.Search;
using Lucene.Net.QueryParsers;

namespace NReco.Lucene
{
    public class LuceneSearchResults : ActionUserControl
    {
        public string IndexDir { get; set; }
        protected IList LuceneSearchResultList { get; set; }
        public Query FinalQuery { get; set; }
        public string SearchTime { get; set; }
        protected IndexSearcher Searcher { get; set; }
        protected Analyzer StandardAnalyzer { get; set; }

        protected void ExecuteSearch()
        {
            DateTime start_date = DateTime.Now;
            BuildQuery();
            BuildSearchResults();
            DataBind();
            DateTime end_date = DateTime.Now;
            SearchTime = String.Format("{0} Second(s) ({1} Millisecond (s))", (end_date - start_date).Seconds, (end_date - start_date).Milliseconds);
        }

        protected virtual void BuildQuery()
        {
            Searcher = new IndexSearcher(IndexDir);
            StandardAnalyzer = new StandardAnalyzer();
        }

        protected virtual void BuildSearchResults()
        {
            Hits hits = Searcher.Search(FinalQuery);
            LuceneSearchResultList = GetDocumentsList(hits);
        }

        protected IList GetDocumentsList(Hits hits)
        {
            IList list = new ArrayList();
            for (int i = 0; i < hits.Length(); ++i)
            {
                list.Add(hits.Doc(i));
            }
            return list;
        }

        //public IDictionary<string,object> GetSearResults()
        //{
        //    //state the file location of the index
        //    string indexFileLocation = @"C:\lucene_index";
        //    Directory dir = FSDirectory.GetDirectory(indexFileLocation, false);

        //    //create an index searcher that will perform the search
        //    IndexSearcher searcher = new IndexSearcher(dir);

        //    //build a query object
        //    Term searchTerm = new Term("content", "fox");
        //    Query query = new TermQuery(searchTerm);

        //    //execute the query
        //    Hits hits = searcher.Search(query);

        //    IDictionary<string, object> dic = new Dictionary<string, object>();
        //    //iterate over the results.
        //    for (int i = 0; i < hits.Length(); i++)
        //    {
        //        Document doc = hits.Doc(i);
        //        dic[i.ToString()] = doc.Get("content");
        //    }
        //    return dic;
        //}
    }
}
