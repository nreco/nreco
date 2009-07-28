using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;
using System.Globalization;
using System.Web.Script.Serialization;

using NReco;
using NReco.Converting;
using NReco.Collections;
using NReco.Web;
using NReco.Web.Site;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;
using NI.Data.RelationalExpressions;

public partial class FlexBoxRelationEditor : CommonRelationEditor {
	
	public string JsScriptName { get; set; }
	public string JsonJsScriptName { get; set; }
	public bool RegisterJs { get; set; }
	
	public string Relex { get; set; }
	
	public FlexBoxRelationEditor() {
		RegisterJs = true;
		JsScriptName = "js/jquery.flexbox.min.js";
		JsonJsScriptName = "js/json.js";
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			RegisterJsFile(JsonJsScriptName);
			RegisterJsFile(JsScriptName);
		}
	}
	
	protected void RegisterJsFile(string jsName) {
		var scriptTag = "<s"+"cript language='javascript' src='"+jsName+"'></s"+"cript>";
		if (!Page.ClientScript.IsStartupScriptRegistered(Page.GetType(), jsName)) {
			Page.ClientScript.RegisterStartupScript(Page.GetType(), jsName, scriptTag, false);
		}
		// one more for update panel
		System.Web.UI.ScriptManager.RegisterClientScriptInclude(Page, Page.GetType(), jsName, "ScriptLoader.axd?path="+jsName);
	}
	
	protected string GetSelectedItemsJson() {
		var dalc = WebManager.GetService<IDalc>(DalcServiceName);
		var relexParser = new RelExQueryParser(false);
		var exprResolver = WebManager.GetService<NI.Common.Expressions.IExpressionResolver>("defaultExprResolver");
		
		var selectedIds = GetSelectedIds();
		if (selectedIds.Length==0)
			return "[]";
		
		var qContext = new Hashtable();
		qContext["q"] = String.Empty;
		Query q = (Query)relexParser.Parse( Convert.ToString( exprResolver.Evaluate( qContext, Relex ) ) );		
		q.Root = new QueryConditionNode( (QField)ValueFieldName, Conditions.In, new QConst(selectedIds) ) & q.Root;
		var ds = new DataSet();
		dalc.Load(ds, q);
		
		var results = new IDictionary<string,object>[ds.Tables[q.SourceName].Rows.Count];
		for (int i=0; i<results.Length; i++)
			results[i] = new Dictionary<string,object>( new DataRowDictionaryWrapper( ds.Tables[q.SourceName].Rows[i] ) );
		
		var json = new JavaScriptSerializer();
		return json.Serialize(results);		
	}
	
	protected override IEnumerable GetControlSelectedIds() {
		var json = new JavaScriptSerializer();
		var selectedList = json.DeserializeObject(selectedValues.Value ) as IEnumerable;
		var res = new ArrayList();
		foreach (IDictionary<string,object> i in selectedList)
			res.Add( i[ValueFieldName] );
		return res.ToArray();
	}
	
}
