#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2014 Vitaliy Fedorchenko
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
using System.Globalization;
using System.Text;
using System.Web;

namespace NReco.Application.Web {

	public class LabelGlobalResourceFilter {

		public ClassKeyRule[] Rules { get; set; }

		public string GetLabel(string label, string context) {
			if (Rules != null) {
				for (int i=0; i<Rules.Length; i++)
					if (Rules[i].Match(context)) {
						var o = HttpContext.GetGlobalResourceObject(Rules[i].ClassKey, label);
						if (o != null)
							return o.ToString();
					}
			}
			return label;
		}

		public abstract class ClassKeyRule {
			public string ClassKey { get; set; }
			public abstract bool Match(string origin);
		}

		public class ContainsRule : ClassKeyRule {
			public string Keyword { get; set; }

			public override bool Match(string origin) {
				return origin!=null ? origin.ToLower().Contains(Keyword.ToLower()) : false;
			}
		}

		public class DefaultRule : ClassKeyRule {
			public override bool Match(string origin) {
				return true;
			}
		}

	}
}
