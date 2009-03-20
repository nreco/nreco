#region License
/*
 * NReco library (http://code.google.com/p/nreco/)
 * Copyright 2008 Vitaliy Fedorchenko
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
using System.Xml;
using System.Xml.XPath;

using NReco;

namespace NReco.Transform {
	
	/// <summary>
	/// File rule context
	/// </summary>
	public class FileRuleContext : Context {
		IFileManager _FileManager;
		string _RuleFileName;
		XPathNavigator _XmlSettings;

		public XPathNavigator XmlSettings {
			get { return _XmlSettings; }
		}

		public string RuleFileName {
			get { return _RuleFileName; }
		}

		public IFileManager FileManager {
			get { return _FileManager; }
		}

		public FileRuleContext(string ruleFileName, IFileManager fm, XPathNavigator nav) { 
			_FileManager = fm;
			_RuleFileName = ruleFileName;
			_XmlSettings = nav;
		}

	}
}
