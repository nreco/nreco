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
using System.Web.UI;
using System.Reflection;
using System.Collections.Generic;
using System.Web.Script.Serialization;

public static class JsHelper  
{
	public static void RegisterJsFile(Page page, string jsName) 
	{
		var isInAsyncPostback = ScriptManager.GetCurrent(page)!=null ? ScriptManager.GetCurrent(page).IsInAsyncPostBack : false;
		
		var pageViewStateProp = page.GetType().GetProperty("ViewState",BindingFlags.Instance|BindingFlags.NonPublic);
		var pageViewState = pageViewStateProp.GetValue(page,null) as StateBag;
		var includesList = (List<string>) (pageViewState["JsHelper.RegisterJsFile"]!=null ? pageViewState["JsHelper.RegisterJsFile"] : (pageViewState["JsHelper.RegisterJsFile"]=new List<string>()) );

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
}
