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
using System.Collections;
using System.Text;

namespace NReco {
	
	/// <summary>
	/// Context based on name => value data context.
	/// </summary>
	[Serializable]
	public class NameValueContext : Context {
		public IDictionary<string,object> Data { get; private set; }

		public NameValueContext() {
			Data = new Dictionary<string,object>();
		}

		public NameValueContext(IDictionary<string,object> map) {
			Data = map;
		}

		public override string ToString() {
			StringBuilder sb = new StringBuilder();
			sb.Append('{');
			bool first = true;
			foreach (string key in Data.Keys) {
				if (!first) sb.Append(',');
				sb.Append(key);
				sb.Append(':');
				sb.Append(Data[key]);
				first = false;
			}
			sb.Append('}');
			return sb.ToString();
		}

		public object this[string key] {
			get { return Data[key]; }
			set { Data[key] = value; }
		}

	}
}
