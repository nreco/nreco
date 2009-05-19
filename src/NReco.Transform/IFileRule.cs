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
using System.Xml.XPath;

namespace NReco.Transform {
	
	/// <summary>
	/// File rule interface
	/// </summary>
	public interface IFileRule : IOperation<FileRuleContext> {
		bool IsMatch(XPathNavigator nav);
	}

	public delegate void FileRuleEventHandler(object sender, FileRuleEventArgs e);

	public class FileRuleEventArgs {
		public IFileRule Rule { get; private set; }
		public string RuleFileName { get; private set; }

		public FileRuleEventArgs(string fName, IFileRule fRule) {
			RuleFileName = fName;
			Rule = fRule;
		}
	}

}
