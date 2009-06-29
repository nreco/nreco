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
using SemWeb;

namespace NReco.SemWeb.Model {

	public class PropertyView {
		public ResourceView Property { get; private set; }
		public bool HasValue {
			get { return Values != null && Values.Count > 0; }
		}
		public bool HasReference {
			get { return References != null && References.Count > 0; }
		}
		public ICollection<object> Values { get; private set; }
		public ICollection<ResourceView> References { get; private set; }

		public object Value {
			get {
				return HasValue ? Values.First() : null;
			}
		}

		public ResourceView Reference {
			get {
				return HasReference ? References.First() : null;
			}
		}

		public PropertyView(ResourceView p, IList<object> values, IList<ResourceView> refs) {
			Property = p;
			Values = values;
			References = refs;
		}
	}


}
