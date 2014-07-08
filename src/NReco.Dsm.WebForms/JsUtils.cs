#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2014 Vitaliy Fedorchenko
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
using System.Net;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Reflection;
using System.Security;
using System.Security.Permissions;
using System.Collections.Generic;
using System.Web.Script.Serialization;

namespace NReco.Dsm.WebForms {

	public static class JsUtils {

		public static T FromJsonString<T>(string str) {
			return new JavaScriptSerializer().Deserialize<T>(str);
		}

		public static object FromJsonString(string str) {
			return new JavaScriptSerializer().DeserializeObject(str);
		}

		public static string ToJsonString(object obj) {
			return new JavaScriptSerializer().Serialize(obj);
		}

		public static T FromJsonUrl<T>(string url) {
			return FromJsonUrl<T>(url, "GET");
		}

		public static T FromJsonUrl<T>(string url, string method) {
			var webReq = WebRequest.Create(url);
			webReq.Method = method;
			var webResponse = webReq.GetResponse();
			try {
				var stream = webResponse.GetResponseStream();
				var jsonRes = new StreamReader(stream).ReadToEnd();
				return FromJsonString<T>(jsonRes);
			} finally {
				webResponse.Close();
			}
		}

	}

}
