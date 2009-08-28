using System;
using System.Web.UI;
using System.Web.Script.Serialization;

public static class JsHelper  
{
	public static void RegisterJsFile(Page page, string jsName) 
	{
		var scriptTag = "<s"+"cript language='javascript' src='"+jsName+"'></s"+"cript>";
		if (!page.ClientScript.IsStartupScriptRegistered(page.GetType(), jsName)) {
			page.ClientScript.RegisterStartupScript(page.GetType(), jsName, scriptTag, false);
		}
		// one more for update panel
		System.Web.UI.ScriptManager.RegisterClientScriptInclude(page, page.GetType(), jsName, "ScriptLoader.axd?path="+jsName);
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
