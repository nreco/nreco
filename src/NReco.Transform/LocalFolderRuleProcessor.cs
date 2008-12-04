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
using System.IO;

using NReco;
using NReco.Logging;

namespace NReco.Transform {
	
	/// <summary>
	/// File rules processor for local filesystem folder (including subfolders)
	/// </summary>
	public class LocalFolderRuleProcessor {
		IFileRule[] _Rules;
		static ILog log = LogManager.GetLogger(typeof(LocalFolderRuleProcessor));

		public IFileRule[] Rules {
			get { return _Rules; }
			set { _Rules = value; }
		}

		public void Execute(string rootFolderName, bool incremental) {
			string[] allFiles = Directory.GetFiles(rootFolderName, "*.*", SearchOption.AllDirectories);
			LocalFileManager fileManager = new LocalFileManager(rootFolderName);
			fileManager.Incremental = incremental;
			log.Write(LogEvent.Info, "Found {0} file(s)", allFiles.Length);

			fileManager.StartSession();
			ExecuteForFiles(allFiles, fileManager);
			fileManager.EndSession();
		}

		protected void ExecuteForFiles(string[] files, IFileManager fileManager) {
			// sort files - order is defined
			Array.Sort<string>(files);
			IDictionary<IFileRule,List<string>> executionPlan = new Dictionary<IFileRule,List<string>>();
			foreach (IFileRule r in Rules)
				executionPlan[r] = new List<string>();
			// build execution plan
			foreach (string filePath in files) {
				foreach (IFileRule r in Rules)
					if (r.MatchFile(filePath, fileManager)) 
						executionPlan[r].Add(filePath);
			}
			// execute in exact order
			foreach (IFileRule r in Rules)
				if (executionPlan[r].Count>0) {
					FileRuleContext ruleContext = new FileRuleContext(executionPlan[r].ToArray(), fileManager);
					log.Write(LogEvent.Info, "Applying {0} for {1} file(s)", r, ruleContext.RuleFileNames.Length);
					r.Execute( ruleContext );
				}
		}


	}
}
