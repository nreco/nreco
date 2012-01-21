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

		public ILuceneFactory Factory { get; set; }
        public IProvider<DataRow, string>[] DeleteDocumentUidProviders { get; set; }
		public IProvider<object, Document>[] DocumentProviders { get; set; }

		public bool Silent { get; set; }

		public bool DelayedIndexing { get; set; }

		protected IList<DataRow> DelayedAddQueue;
		protected IList<DataRow> DelayedUpdateQueue;

		public DataRowIndexer() {
			Silent = true;
			DelayedIndexing = false;
			DelayedAddQueue = new List<DataRow>();
			DelayedUpdateQueue = new List<DataRow>();
		}

		public void Delete(DataRow r) {
			DeleteInternal(r);
		}

		protected virtual void DeleteInternal(DataRow r) {
			try {
				if (log.IsEnabledFor(LogEvent.Debug))
					log.Write(LogEvent.Debug, "Deleting document by datarow (table={0})", r != null && r.Table != null ? r.Table.TableName : "NULL");
				var indexWriter = Factory.CreateWriter();
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
		
		protected DataRow CloneDataRow(DataRow r) {
			var dsCopy = r.Table.DataSet.Clone();
			dsCopy.Tables[r.Table.TableName].ImportRow(r);
			return dsCopy.Tables[r.Table.TableName].Rows.Count>0 ? dsCopy.Tables[r.Table.TableName].Rows[0] : null;
		}
		
		public void RunDelayedIndexing() {
			// add queue
			foreach (var r in DelayedAddQueue) {
				AddInternal(r);
			}
			DelayedAddQueue.Clear();
			// update queue
			foreach (var r in DelayedUpdateQueue) {
				UpdateInternal(r);
			}			
		}

		public void Update(DataRow r) {
			if (DelayedIndexing) {
				var rCopy = CloneDataRow(r);
				if (rCopy!=null)
					DelayedUpdateQueue.Add(rCopy);
			} else {
				UpdateInternal(r);
			}
		}

		protected virtual void UpdateInternal(DataRow r) {
			try {
				if (log.IsEnabledFor(LogEvent.Debug))
					log.Write(LogEvent.Debug, "Updating document by datarow (table={0})", r != null && r.Table != null ? r.Table.TableName : "NULL");
				var indexWriter = Factory.CreateWriter();
                try {
				    foreach (var prv in DocumentProviders) {
					    var doc = prv.Provide(r);
					    if (doc == null) {
						    log.Write(LogEvent.Debug, "Updating document by datarow - skipped (table={0})", r != null && r.Table != null ? r.Table.TableName : "NULL");
					    } else {
							indexWriter.UpdateDocument(new Term(DocumentComposer.UidFieldName, doc.Get(DocumentComposer.UidFieldName)), doc);
						}
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
			if (DelayedIndexing) {
				var rCopy = CloneDataRow(r);
				if (rCopy!=null)
					DelayedAddQueue.Add(rCopy);
			} else {
				AddInternal(r);
			}
		}

		protected virtual void AddInternal(DataRow r) {
			try {
				if (log.IsEnabledFor(LogEvent.Debug))
					log.Write(LogEvent.Debug, "Indexing document by datarow (table={0})", r != null && r.Table!=null ? r.Table.TableName : "NULL");
				var indexWriter = Factory.CreateWriter();
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
