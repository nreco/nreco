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
using System.Xml;
using System.IO;
using System.Text;

using NReco.Logging;

namespace NReco.Transform {

	/// <summary>
	/// Resolves external XML resources named by a URI using IFileManager.
	/// </summary>
	public class FileManagerXmlResolver : XmlResolver {
		IFileManager _FileManager;
		string _BasePath;
		static ILog log = LogManager.GetLogger(typeof(FileManagerXmlResolver));

		protected IFileManager FileManager {
			get { return _FileManager; }
			set { _FileManager = value; }
		}

		protected string BasePath {
			get { return _BasePath; }
		}

		public FileManagerXmlResolver(IFileManager fileManager, string basePath) {
			FileManager = fileManager;
			_BasePath = basePath;
		}

		public override System.Net.ICredentials Credentials {
			set { /* ignore */ }
		}

		public override object GetEntity(Uri absoluteUri, string role, Type ofObjectToReturn) {
			if ((ofObjectToReturn != null) && (ofObjectToReturn != typeof(Stream))) {
				throw new XmlException("Unsupported object type");
			}
			log.Write(LogEvent.Debug, new { Uri = absoluteUri });

			string path = RemoveSchemePrefix(absoluteUri.ToString());

			if (path.Length < 2 || path[1] != ':')
				path = "/" + path; // unix filesystem

			string content = FileManager.Read(path);
			if (path.IndexOfAny(new char[] { '*', '?' }) > 0) {
				content = "<root>"+content+"</root>";
			}
			return new MemoryStream( Encoding.UTF8.GetBytes(content) );
		}

		protected string RemoveSchemePrefix(string s) {
			if (s.StartsWith("file:///"))
				return s.Substring(8);
			return s;
		}

		public override Uri ResolveUri(Uri baseUri, string relativeUri) {
			// check for bad base (in console mode XIncludingReader pushes path to its DLL - ignore it)
			if (baseUri == null || baseUri.ToString().ToLower().Contains(".dll")) {
				return new Uri( "file:///"+ Path.Combine( BasePath, relativeUri));
			}
			var basePath = Path.GetDirectoryName( RemoveSchemePrefix(baseUri.ToString()) );
			return new Uri("file:///"+Path.Combine(basePath, relativeUri));
		}

	}

}
