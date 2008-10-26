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

using NReco;

namespace NReco.Transform {
	
	public class FileRuleContext : Context {
		IFileManager _FileManager;
		string[] _RuleFileNames;

		public string[] RuleFileNames {
			get { return _RuleFileNames; }
		}

		public IFileManager FileManager {
			get { return _FileManager; }
		}

		public FileRuleContext(string[] ruleFileNames, IFileManager fm) { 
			_FileManager = fm;
			_RuleFileNames = ruleFileNames;
		}

	}
}
