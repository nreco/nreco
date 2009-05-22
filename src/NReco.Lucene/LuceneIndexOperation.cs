using System;
using System.Data;
using System.Collections;
using System.Collections.Specialized;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.Threading;
using System.Globalization;

using NI.Data.Dalc;

using Lucene.Net;
using Lucene.Net.Analysis;
using Lucene.Net.Analysis.Standard;
using Lucene.Net.Documents;
using Lucene.Net.Index;
using Lucene.Net.Store;

namespace NReco.Lucene
{

    public class LuceneIndexOperation : IOperation<object>
    {
       public enum OperationType 
        {
            Create,
            Update,
            Delete
        }

       public enum TokenizedTypes
       {
           no,
           no_norms,
           tokenized,
           un_tokenized
       }

       public enum StoreTypes
       {
           no,
           compress,
           yes
       }

       public enum IndexParameters
       {
           tokenizing,
           store
       }

       public enum IndexTypes
       {
           auto,
           full
       }

       public DalcDictionaryListProvider IndexingContentProvider { get; set; }
       public IDictionary<string,IDictionary<string,string>> ColumnsInfoProvider { get; set; }
       public LuceneConfiguration IndexConfiguration { get; set; }
       public string CurrentOperationType { get; set; }
       private string _IndexDir;
       public string IndexDir
       {
           get { return System.IO.Path.Combine(IndexConfiguration.IndexPath, _IndexDir); }
           set { _IndexDir = value; }
       }
       public string IndexType { get; set; }

       public void ProvideIndexingByOperationType(DataRow row, IndexWriter writer)
       {
 
           if(OperationType.Delete.ToString().ToLower() == CurrentOperationType)
           {
               writer.DeleteDocuments(new Term("id", Convert.ToString(row["id"])));
           }
           if (OperationType.Create.ToString().ToLower() == CurrentOperationType || OperationType.Update.ToString().ToLower() == CurrentOperationType)
           {
               Document doc = new Document();
               foreach (KeyValuePair<string,IDictionary<string,string>> pair in ColumnsInfoProvider)
               {
                   doc.Add(IndexFieldCreation(Convert.ToString(pair.Key), Convert.ToString(row[Convert.ToString(pair.Key)])));
               }
               //
               if (OperationType.Create.ToString().ToLower() == CurrentOperationType)
               {
                   writer.AddDocument(doc);
               }
               if (OperationType.Update.ToString().ToLower() == CurrentOperationType)
               {
                   writer.UpdateDocument(new Term("id", Convert.ToString(row["id"])), doc);
               }
           }
       }

       public void ProvideFullIndexing(IndexWriter writer)
       {
           
           IDictionary[] data = IndexingContentProvider.GetDictionaryList(null);
           foreach (IDictionary item in data)
           {
               Document doc = new Document();
               foreach (object keyObj in item.Keys)
               {
                   doc.Add(IndexFieldCreation(Convert.ToString(keyObj), Convert.ToString(item[keyObj])));
               }
               writer.AddDocument(doc);
           }
       }

       public Field IndexFieldCreation(string fieldName, string fieldValue)
       {
           IDictionary<string, string> dic = ColumnsInfoProvider[fieldName];
           
           string store_param = Convert.ToString(dic[IndexParameters.store.ToString()]).ToLower();
           string tokenize_param = Convert.ToString(dic[IndexParameters.tokenizing.ToString()]).ToLower();

           Field f = new Field(fieldName, fieldValue, (store_param == StoreTypes.no.ToString()) ? Field.Store.NO : (store_param == StoreTypes.compress.ToString()) ? Field.Store.COMPRESS : Field.Store.YES, (tokenize_param == TokenizedTypes.no.ToString()) ? Field.Index.NO : (tokenize_param == TokenizedTypes.no_norms.ToString()) ? Field.Index.NO_NORMS : (tokenize_param == TokenizedTypes.un_tokenized.ToString()) ? Field.Index.UN_TOKENIZED : Field.Index.TOKENIZED);

           return f;
       }

       public void Execute(object context)
       {
           CultureInfo culture = CultureInfo.CurrentCulture;
           System.Threading.Thread.CurrentThread.CurrentCulture = CultureInfo.InvariantCulture;
           DateTime start = DateTime.Now;

           if (IndexTypes.auto.ToString() == IndexType.ToLower())
           {
               ExecuteAutoIndex(context);
           }
           else if (IndexTypes.full.ToString() == IndexType.ToLower())
           {
               ExecuteFullIndex(context);
           }
           DateTime end = DateTime.Now;
           Trace.WriteLine(String.Format("Time = {0} seconds", (end - start).Seconds));
           System.Threading.Thread.CurrentThread.CurrentCulture = culture;
       }

       public void ExecuteAutoIndex(object context)
       {
            DataRow dataRow = (DataRow)((ListDictionary)context)["row"];
            IndexWriter indexWriter = new IndexWriter(IndexDir, new StandardAnalyzer(), false);
            indexWriter.SetUseCompoundFile(true);
            Document doc = new Document();

            ProvideIndexingByOperationType(dataRow, indexWriter);

            indexWriter.Optimize();
            indexWriter.Close();
        }

        public void ExecuteFullIndex(object context)
        {
            IndexWriter indexWriter = new IndexWriter(IndexDir, new StandardAnalyzer(), true);
            indexWriter.SetUseCompoundFile(true);
            Document doc = new Document();

            ProvideFullIndexing(indexWriter);

            indexWriter.Optimize();
            indexWriter.Close();
        }
    }
}
