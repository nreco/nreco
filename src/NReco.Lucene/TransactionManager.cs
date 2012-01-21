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

namespace NReco.Lucene {
	
	public class TransactionManager {

		public ILuceneFactory[] Factories { get; set; }

		internal Transaction Current = null;

		public TransactionManager() {

		}

		public TransactionManager(ILuceneFactory factory) {
			Factories = new[] { factory };
		}

		public TransactionManager(ILuceneFactory[] factories) {
			Factories = factories;
		}

		public void Begin() {
			if (Current == null) {
				Current = new Transaction();
				foreach (var factory in Factories)
					factory.Transaction = Current;
			}
		}

		public void Commit() {
			if (Current != null) {
				Current.Commit();
				foreach (var factory in Factories)
					factory.Transaction = null;
				Current = null;
			}

		}

		public void Rollback() {
			if (Current != null) {
				Current.Rollback();
				foreach (var factory in Factories)
					factory.Transaction = null;
				Current = null;
			}
		}

	}

}
