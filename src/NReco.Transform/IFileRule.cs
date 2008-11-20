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

namespace NReco.Transform {
	
	/// <summary>
	/// File rule interface
	/// </summary>
	public interface IFileRule : IOperation<FileRuleContext> {
		bool MatchFile(string filePath, IFileManager fileManager);
		void Execute(FileRuleContext ruleContext);
	}
}
