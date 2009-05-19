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
using System.Linq;
using System.Text;
using System.Security.Cryptography;

namespace NReco.Web.Site.Security {
	
	public class Md5PasswordEncrypter : IPasswordEncrypter {

		public int LengthLimit { get; set; }

		public Md5PasswordEncrypter() {
			LengthLimit = 50;
		}

		public string Encrypt(string pwd) {
			MD5 md5 = new MD5CryptoServiceProvider();

			byte[] hash = md5.ComputeHash(System.Text.Encoding.UTF8.GetBytes(pwd));
			string strResult = Convert.ToBase64String(hash);
			return LengthLimit < 0 || strResult.Length <= LengthLimit ? strResult : strResult.Substring(0, LengthLimit);
		}

		public string Decrypt(string pwd) {
			throw new NotSupportedException();
		}

	}
}
