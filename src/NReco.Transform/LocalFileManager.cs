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
using System.IO;
using System.Text;

namespace NReco.Transform {
	
	/// <summary>
	/// File manager implementation for local filesystem.
	/// </summary>
	/// <remarks>
	/// For performance local file manager caches file contents.
	/// </remarks>
	public class LocalFileManager : IFileManager {
		string _RootPath = null;

		public string RootPath {
			get { return _RootPath; }
			set { _RootPath = value; }
		}

		IDictionary<string,string> CachedContent = new Dictionary<string,string>();

		public LocalFileManager() {
		}

		public LocalFileManager(string rootPath) {
			RootPath = rootPath;
		}

		protected string GetFullPath(string path) {
			if (Path.IsPathRooted(path))
				return path;
			return RootPath!=null ? Path.Combine( RootPath, path) : path;
		}

		public string Read(string filePath) {
			try {
				// lets allow 'masks' - this simplifies mass includes
				if (filePath.IndexOfAny(new char[]{'*','?'})>=0) {
					string[] foundFiles = Directory.GetFiles(RootPath, filePath,SearchOption.AllDirectories);
					StringBuilder commonContent = new StringBuilder();
					foreach (string foundFilePath in foundFiles)
						commonContent.Append( Read( foundFilePath) );
					return commonContent.ToString();
				}
				string fName = GetFullPath(filePath);

				if (CachedContent.ContainsKey(fName))
					return CachedContent[fName];
				using (FileStream fs = new FileStream(fName, FileMode.Open, FileAccess.Read)) {
					string content = new StreamReader(fs).ReadToEnd();
					CachedContent[fName] = content;
					return content;
				}
			} catch (Exception ex) {
				throw new Exception( String.Format("Cannot read {0}: {1}",filePath,ex.Message,ex));
			}
		}

		public void Write(string filePath, string fileContent) {
			string fName = GetFullPath(filePath);
			CachedContent[fName] = fileContent;
			using (FileStream fs = new FileStream(fName, FileMode.Create, FileAccess.Write)) {
				StreamWriter wr = new StreamWriter(fs);
				wr.Write(fileContent);
				wr.Flush();
			}	
			
		}

	}
}
