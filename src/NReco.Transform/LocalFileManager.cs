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
using System.Runtime.Serialization.Formatters.Binary;
using System.Runtime.Serialization;
using NReco.Logging;

namespace NReco.Transform {
	
	/// <summary>
	/// File manager implementation for local filesystem.
	/// </summary>
	/// <remarks>
	/// For performance local file manager caches file contents.
	/// </remarks>
	public class LocalFileManager : IFileManager {
		string _RootPath = null;
		bool _Incremental = false;
		string _OriginalContentCacheFileName = ".nreco/originalcontentcache.dat";
		static ILog log = LogManager.GetLogger(typeof(LocalFileManager));

		public string OriginalContentCacheFileName {
			get { return _OriginalContentCacheFileName; }
			set { _OriginalContentCacheFileName = value; }
		}

		public string RootPath {
			get { return _RootPath; }
			set { _RootPath = value; }
		}

		public bool Incremental {
			get { return _Incremental; }
			set { _Incremental = value; }
		}

		public event FileManagerEventHandler Reading;
		public event FileManagerEventHandler Writing;

		IDictionary<string,string> ContentCache = new Dictionary<string,string>();
		IDictionary<string,string> OriginalContentCache = new Dictionary<string,string>();
		DateTime OriginalContentCacheTimestamp;
		DateTime SessionStartTimestamp;

		public LocalFileManager() {
		}

		public LocalFileManager(string rootPath) {
			RootPath = rootPath;
		}


		protected string GetFullPath(string path) {
			if (!Path.IsPathRooted(path) && RootPath!=null) {
				path = Path.Combine(RootPath, path);
			}
			return Path.GetFullPath(path);
		}

		public void ResetFile(string path) {
			var fullPath = GetFullPath(path);
			if (OriginalContentCache.ContainsKey(fullPath))
				OriginalContentCache.Remove(fullPath);
		}

		public void StartSession() {
			ContentCache.Clear();
			if (Incremental) {
				string cacheFileName = GetFullPath(OriginalContentCacheFileName);
				if (File.Exists(cacheFileName)) {
					// lets remember original cache timestamp
					OriginalContentCacheTimestamp = File.GetLastWriteTime(cacheFileName);
					log.Write(LogEvent.Info,
						new{Msg="found original content cache file",Timestamp=OriginalContentCacheTimestamp}
					);
					BinaryFormatter formatter = new BinaryFormatter();
					using (FileStream fs = new FileStream(cacheFileName, FileMode.Open, FileAccess.Read)) {
						try {
							OriginalContentCache = formatter.Deserialize(fs) as IDictionary<string, string>;
						} catch (Exception ex) {
							log.Write(LogEvent.Error,
								new{Action="read original content cache",Filename=cacheFileName,Exception=ex}
							);
						}
					}
				}
				if (OriginalContentCache == null) {
					OriginalContentCache = new Dictionary<string, string>();
					OriginalContentCacheTimestamp = DateTime.Now;
				}
			} else {
				OriginalContentCache.Clear();
			}
			SessionStartTimestamp = DateTime.Now;
		}

		public void EndSession() {
			if (Incremental && OriginalContentCache!=null) {
				string cacheFileName = GetFullPath(OriginalContentCacheFileName);
				string cacheFileDir = Path.GetDirectoryName(cacheFileName);
				BinaryFormatter formatter = new BinaryFormatter();
				if (!Directory.Exists( cacheFileDir )) {
					Directory.CreateDirectory(cacheFileDir);
				}
				using (FileStream fs = new FileStream(cacheFileName, FileMode.Create, FileAccess.Write)) {
					formatter.Serialize(fs, OriginalContentCache);
				}
			}
		}

		public string Read(string filePath) {
			try {
				// lets allow 'masks' - this simplifies mass includes
				if (filePath.IndexOfAny(new char[]{'*','?'})>=0) {
					string[] foundFiles = Directory.GetFiles(RootPath, filePath,SearchOption.AllDirectories);
					if (foundFiles.Length == 0)
						return null;
					StringBuilder commonContent = new StringBuilder();
					foreach (string foundFilePath in foundFiles)
						commonContent.Append( Read( foundFilePath) );
					return commonContent.ToString();
				}
				string fName = GetFullPath(filePath);
				if (Reading != null)
					Reading(this, new FileManagerEventArgs(fName));

				if (ContentCache.ContainsKey(fName))
					return ContentCache[fName];
				// file is accessed for the first time
				// may be original content exists?
				if (OriginalContentCache.ContainsKey(fName)) {
					DateTime fileTimestamp = File.GetLastWriteTime(fName);
					if (fileTimestamp <= OriginalContentCacheTimestamp) {
						ContentCache[fName] = OriginalContentCache[fName];
						return ContentCache[fName];
					} else
						OriginalContentCache.Remove(fName);
				}

				using (FileStream fs = new FileStream(fName, FileMode.Open, FileAccess.Read)) {
					string content = new StreamReader(fs).ReadToEnd();
					ContentCache[fName] = content;
					return content;
				}
			} catch (Exception ex) {
				throw new Exception( String.Format("Cannot read {0}: {1}",filePath,ex.Message,ex));
			}
		}

		public void Write(string filePath, string fileContent) {
			string fName = GetFullPath(filePath);
			if (Writing != null)
				Writing(this, new FileManagerEventArgs(fName));

			if (Incremental) {
				if (ContentCache.ContainsKey(fName) && File.Exists(fName)) {
					// target file was accessed in this session - possibly we should save its original content.
					DateTime fileTimeStamp = File.GetLastWriteTime(fName);
					// lets treat current content cache as original content if:
					// 1) wasn't registered as original content
					// 2) or it was updated _after_ last session but not in this session
					if (!OriginalContentCache.ContainsKey(fName) || 
						(fileTimeStamp>OriginalContentCacheTimestamp &&
						fileTimeStamp<SessionStartTimestamp)) {
						// lets just save original content
						OriginalContentCache[fName] = ContentCache[fName];
					}
				}
			}

			ContentCache[fName] = fileContent;
			var dirName = Path.GetDirectoryName(fName);
			if (!Directory.Exists(dirName))
				Directory.CreateDirectory(dirName); 
			using (FileStream fs = new FileStream(fName, FileMode.Create, FileAccess.Write)) {
				StreamWriter wr = new StreamWriter(fs);
				wr.Write(fileContent);
				wr.Flush();
			}	
			
		}

	}
}
