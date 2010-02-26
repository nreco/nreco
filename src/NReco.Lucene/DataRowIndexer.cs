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
using System.Data;

using NReco;
using NReco.Logging;
using Lucene.Net;
using Lucene.Net.Index;
using Lucene.Net.Analysis;
using Lucene.Net.Analysis.Standard;
using Lucene.Net.Documents;

namespace NReco.Lucene {

	/// <summary>
	/// Facade for indexing data from DataRow objects
	/// </summary>
	public class DataRowIndexer {

		protected static ILog log = LogManager.GetLogger(typeof(DataRowIndexer));

		public IProvider<object, IndexWriter> IndexWriterProvider { get; set; }
        public IProvider<DataRow, string>[] DeleteDocumentUidProviders { get; set; }
		public IProvider<object, Document>[] DocumentProviders { get; set; }

		public bool Silent { get; set; }

		public DataRowIndexer() {
			Silent = true;
		}

		public void Delete(DataRow r) {
			try {
				if (log.IsEnabledFor(LogEvent.Debug))
					log.Write(LogEvent.Debug, "Deleting document by datarow (table={0})", r != null && r.Table != null ? r.Table.TableName : "NULL");
				var indexWriter = IndexWriterProvider.Provide();
                try {
                    foreach (var prv in DeleteDocumentUidProviders) {
                        var docUid = prv.Provide(r);
                        if (docUid != null) {
                            indexWriter.DeleteDocuments(new Term(DocumentComposer.UidFieldName, docUid));
                        }
                    }
                } finally {
                    indexWriter.Close();
                }
			} catch (Exception ex) {
				HandleException("Delete", r, ex);
			}
		}

		public void Update(DataRow r) {
			try {
				if (log.IsEnabledFor(LogEvent.Debug))
					log.Write(LogEvent.Debug, "Updating document by datarow (table={0})", r != null && r.Table != null ? r.Table.TableName : "NULL");
				var indexWriter = IndexWriterProvider.Provide();
                try {
				    foreach (var prv in DocumentProviders) {
					    var doc = prv.Provide(r);
					    if (doc == null) {
						    log.Write(LogEvent.Debug, "Updating document by datarow - skipped (table={0})", r != null && r.Table != null ? r.Table.TableName : "NULL");
					    } else 
						    indexWriter.UpdateDocument(new Term(DocumentComposer.UidFieldName, doc.Get(DocumentComposer.UidFieldName)), doc);
				    }
                } finally {
                    indexWriter.Close();
                }
				indexWriter.Close();
			} catch (Exception ex) {
				HandleException("Update", r, ex);
			}
		}

		public void Add(DataRow r) {
			try {
				if (log.IsEnabledFor(LogEvent.Debug))
					log.Write(LogEvent.Debug, "Indexing document by datarow (table={0})", r != null && r.Table!=null ? r.Table.TableName : "NULL");
				var indexWriter = IndexWriterProvider.Provide();
                try {
				    foreach (var prv in DocumentProviders) {
					    var doc = prv.Provide(r);
					    indexWriter.AddDocument(doc);
				    }
				} finally {
                    indexWriter.Close();
                }
			} catch (Exception ex) {
				HandleException("Add", r, ex);
			}
		}

		protected void HandleException(string action, DataRow r, Exception ex) {
			if (log.IsEnabledFor(LogEvent.Error))
				log.Write(LogEvent.Error, new { Action = action, Exception = ex, SourceName = r.Table.TableName });
			if (!Silent)
				throw new Exception(String.Format("{2} index failed for '{0}': {1}", r.Table.TableName, ex.Message, action), ex);
		}


	}

}
