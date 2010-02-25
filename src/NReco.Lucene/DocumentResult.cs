using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using NReco;
using Lucene.Net.Documents;

namespace NReco.Lucene
{
    public class DocumentResult 
    {
        public Document Document { get; set; }
        public float Score { get; set; }

        public DocumentResult()
        { }

        public DocumentResult(Document doc, float score)
        {
            Document = doc;
            Score = score;
        }
    }
}
