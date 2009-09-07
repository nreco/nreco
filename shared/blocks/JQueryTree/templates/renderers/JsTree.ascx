<%@ Control Language="c#" AutoEventWireup="false" CodeFile="JsTree.ascx.cs" Inherits="JsTree" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>
<link rel="stylesheet" type="text/css" href="css/jsTree/tree_component.css" />

<span id="<%=ClientID %>">
	<div id="<%=ClientID %>jsTree"></div>
</span>

<script language="javascript">
jQuery(function(){
	jQuery('#<%=ClientID %>jsTree').tree(
		{ 
			data : {
				type : 'json',
				method : 'get',
				async : true,
				async_data : function (NODE) { return { provider : '<%=DataProviderName %>', context : $(NODE).attr("<%=ValueFieldName %>") || <%=RootLevelValue!=null ? String.Format("'{0}'",RootLevelValue) : "null" %> } },
				url : '<%=VirtualPathUtility.AppendTrailingSlash(WebManager.BasePath) %>ProviderAjaxHandler.axd'
			},
			ui : {
				dots : false,
				theme_path : '<%=VirtualPathUtility.AppendTrailingSlash(WebManager.BasePath) %>css/jsTree/',
				theme_name  : "default"
			},
			callback : {
				onJSONdata  : function(DATA,TREE_OBJ) { 
					var treeData = [];
					$.each(DATA, function() {
						treeData.push( {
							attributes: this,
							data : this.<%=TextFieldName %>,
							state: "closed"
						});
					});
					return treeData; 
				},
				oncreate : function(NODE,REF_NODE,TYPE,TREE_OBJ,RB) { 
					alert( $( TREE_OBJ.parent( NODE ) ).attr('id') );
				},
				onrename : function(NODE,LANG,TREE_OBJ,RB) { 
					alert( $(NODE).find('a').html() );
				},
				onmove : function(NODE,REF_NODE,TYPE,TREE_OBJ,RB) { 
					alert( $(REF_NODE).attr('id') );
				},
				ondelete : function(NODE, TREE_OBJ,RB) { 
					alert( $(NODE).attr('id') );
				}
			}
		}
	);
});
</script>
