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
		static readonly Uri AbsoluteBaseUri = new Uri("http://local/");
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

			string relativePath = AbsoluteBaseUri.MakeRelative(absoluteUri);
			if (relativePath.StartsWith("file:///"))
				relativePath = relativePath.Substring(8);
			string content = FileManager.Read(relativePath);
			if ( relativePath.IndexOfAny( new char[] {'*','?'} )>0 ) {
				content = "<root>"+content+"</root>";
			}
			return new MemoryStream( Encoding.ASCII.GetBytes(content) );
		}

		public override Uri ResolveUri(Uri baseUri, string relativeUri) {
			if (baseUri!=null && baseUri.IsAbsoluteUri && baseUri.Scheme!="file") {
				return new Uri(baseUri, relativeUri);
			} else {
				return new Uri(AbsoluteBaseUri, Path.Combine(BasePath, relativeUri));
			}
		}

	}

}
