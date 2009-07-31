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

	public class DataRowIndexer {

		protected static ILog log = LogManager.GetLogger(typeof(DataRowIndexer));

		public IProvider<object, IndexWriter> IndexWriterProvider { get; set; }

		public IProvider<object, Document>[] DocumentProviders { get; set; }

		public bool Silent { get; set; }

		public DataRowIndexer() {
			Silent = true;
		}

		public void Delete(DataRow r) {
			try {
				var indexWriter = IndexWriterProvider.Provide();
				foreach (var prv in DocumentProviders) {
					var doc = prv.Provide(r);
					indexWriter.DeleteDocuments(new Term(DocumentComposer.UidFieldName, doc.Get(DocumentComposer.UidFieldName)));
				}
				indexWriter.Close();
			} catch (Exception ex) {
				HandleException("Delete", r, ex);
			}
		}

		public void Update(DataRow r) {
			try {
				var indexWriter = IndexWriterProvider.Provide();
				foreach (var prv in DocumentProviders) {
					var doc = prv.Provide(r);
					indexWriter.UpdateDocument(new Term(DocumentComposer.UidFieldName, doc.Get(DocumentComposer.UidFieldName)), doc);
				}
				indexWriter.Close();
			} catch (Exception ex) {
				HandleException("Update", r, ex);
			}
		}

		public void Add(DataRow r) {
			try {
				var indexWriter = IndexWriterProvider.Provide();
				foreach (var prv in DocumentProviders) {
					var doc = prv.Provide(r);
					indexWriter.AddDocument(doc);
				}
				indexWriter.Close();
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
