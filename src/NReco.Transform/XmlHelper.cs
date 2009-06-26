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
using System.Text;

namespace NReco.Transform {
	
	public static class XmlHelper {

		public static string DecodeSpecialChars(string s) {
			// there are 4 chars that may be needed in output content but could be hardly generated from XSL
			var sb = new StringBuilder(s);
			sb.Replace("@@lt;", "<").Replace("@@gt;", ">").Replace("@@at;", "@").Replace("@@amp;", "&");
			return sb.ToString();
		}

	}
}
