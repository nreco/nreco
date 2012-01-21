using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using NReco;
using Lucene.Net;
using Lucene.Net.Index;
using Lucene.Net.Search;
using Lucene.Net.Analysis;

namespace NReco.Lucene {
	
	public interface ILuceneFactory {
		
		Transaction Transaction { get; set; }

		Analyzer GetAnalyser();
		
		IndexWriter CreateWriter();
		
		IndexSearcher CreateSearcher();
		
		IndexReader CreateReader();
		
		void Clear();
		
	}
}
