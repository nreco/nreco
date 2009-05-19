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
using System.Xml;
using System.Xml.XPath;

using NReco;

namespace NReco.Transform {
	
	public class XmlConfigRuleContext : Context {
		IFileManager _FileManager;
		IXPathNavigable _RuleConfig;

		public IXPathNavigable RuleConfig {
			get { return _RuleConfig; }
		}

		public IFileManager FileManager {
			get { return _FileManager; }
		}

		public XmlConfigRuleContext(IXPathNavigable ruleConfig, IFileManager fm) { 
			_FileManager = fm;
			_RuleConfig = ruleConfig;
		}

	}
}
