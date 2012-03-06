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
using System.Net;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Reflection;
using System.Security;
using System.Security.Permissions;
using System.Collections.Generic;
using System.Web.Script.Serialization;

public static class JsHelper  
{
	public static void RegisterJsFile(Page page, string jsName) 
	{
		var isInAsyncPostback = ScriptManager.GetCurrent(page)!=null ? ScriptManager.GetCurrent(page).IsInAsyncPostBack : false;
		
		List<string> includesList;
		var canUseReflection = SecurityManager.IsGranted( new ReflectionPermission(PermissionState.Unrestricted));
		if (canUseReflection) {
			// this is preferred from security/stability way to track registered javascripts
			var pageViewStateProp = page.GetType().GetProperty("ViewState",BindingFlags.Instance|BindingFlags.NonPublic);
			var pageViewState = pageViewStateProp.GetValue(page,null) as StateBag;
			includesList = (List<string>) (pageViewState["JsHelper.RegisterJsFile"]!=null ? 
				pageViewState["JsHelper.RegisterJsFile"] : 
				(pageViewState["JsHelper.RegisterJsFile"]=new List<string>()) );
		} else {
			if (page.Items["JsHelper.RegisterJsFile"]==null) {
				includesList = new List<string>();
				page.Items["JsHelper.RegisterJsFile"] = includesList;
				// try load from special input hidden
				if (page.Form.Attributes["JsHelperRegisterJsFile"]!=null) {
					includesList.AddRange( page.Form.Attributes["JsHelperRegisterJsFile"].Split(';') );
				}
			}
			includesList = (List<string>) (page.Items["JsHelper.RegisterJsFile"]);
		}

		// one more for update panel
		if (isInAsyncPostback) {
			if (!includesList.Contains(jsName)) {
				System.Web.UI.ScriptManager.RegisterClientScriptInclude(page, page.GetType(), jsName, "ScriptLoader.axd?path="+jsName);
				includesList.Add(jsName);
			}
		} else {
			// usual includes
			if (!page.ClientScript.IsClientScriptIncludeRegistered(page.GetType(), jsName)) {
				page.ClientScript.RegisterClientScriptInclude(page.GetType(), jsName, jsName);
				page.Items[ jsName ] = true;
				includesList.Add(jsName);
			}
		}
		
		if (!canUseReflection) {
			// refresh info about included javascripts
			page.Form.Attributes["JsHelperRegisterJsFile"] = String.Join(";", includesList.ToArray() );
		}
	}
	
	public static T FromJsonString<T>(string str)
	{
		return new JavaScriptSerializer().Deserialize<T>(str);
	}
	
	public static object FromJsonString(string str)
	{
		return new JavaScriptSerializer().DeserializeObject(str);
	}
	
	public static string ToJsonString(object obj)
	{
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
