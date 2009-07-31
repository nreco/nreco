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

using Lucene.Net.Index;
using Lucene.Net.Analysis;

namespace NReco.Lucene {

	internal class TransactIndexWriter : IndexWriter {

		internal bool IsInTransaction = false;

		public TransactIndexWriter(string dir, Analyzer analyzer, bool create, IndexWriter.MaxFieldLength fldLen) :
			base(dir, analyzer, create, fldLen) {
		}

		public override void Close() {
			if (!IsInTransaction)
				base.Close();
			// transaction will close writer on commit
		}

	}
}
