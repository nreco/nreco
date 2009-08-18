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
using System.Data;
using System.Text.RegularExpressions;
using NetRegex = System.Text.RegularExpressions.Regex;

namespace NReco.OGNL.Helpers {
	
	public static class Regex {

		public static bool Match(string s, string regex) {
			return NetRegex.IsMatch(s, regex, RegexOptions.Singleline);
		}

		public static string Replace(string s, string regex, string replaceWith) {
			return NetRegex.Replace(s, regex, replaceWith, RegexOptions.Singleline);
		}
	}
}
