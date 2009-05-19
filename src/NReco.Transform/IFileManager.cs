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
using System.IO;
using System.Text;

namespace NReco.Transform {
	
	public interface IFileManager {
		string Read(string filePath);
		void Write(string filePath, string fileContent);
	}

	public delegate void FileManagerEventHandler(object sender, FileManagerEventArgs e);

	public class FileManagerEventArgs {
		public string FileName { get; private set; }

		public FileManagerEventArgs(string fName) {
			FileName = fName;
		}
	}

}
