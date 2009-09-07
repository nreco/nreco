<%@ Control Language="c#" AutoEventWireup="false" CodeFile="JsTree.ascx.cs" Inherits="JsTree" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>
<link rel="stylesheet" type="text/css" href="css/jsTree/tree_component.css" />

<span id="<%=ClientID %>">
	<div id="<%=ClientID %>jsTree"></div>
	<div class="toolboxContainer">
		<span>
			<a class="addItem" href="javascript:void(0)"><%=WebManager.GetLabel("Add Item",this) %></a>
		</span>
	</div>
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
				theme_name  : "default",
				context : [ 
					{
						id      : "create",
						label   : "<%=WebManager.GetLabel("Create",this).Replace("'", "\\'") %>", 
						icon    : "create.png",
						visible : function (NODE, TREE_OBJ) { if(NODE.length != 1) return false; return TREE_OBJ.check("creatable", NODE); }, 
						action  : function (NODE, TREE_OBJ) { TREE_OBJ.create(false, TREE_OBJ.get_node(NODE)); } 
					},
					"separator",
					{ 
						id      : "rename",
						label   : "<%=WebManager.GetLabel("Rename",this).Replace("'", "\\'") %>", 
						icon    : "rename.png",
						visible : function (NODE, TREE_OBJ) { if(NODE.length != 1) return false; return TREE_OBJ.check("renameable", NODE); }, 
						action  : function (NODE, TREE_OBJ) { TREE_OBJ.rename(); } 
					},
					{ 
						id      : "delete",
						label   : "<%=WebManager.GetLabel("Delete",this).Replace("'", "\\'") %>",
						icon    : "remove.png",
						visible : function (NODE, TREE_OBJ) { var ok = true; $.each(NODE, function () { if(TREE_OBJ.check("deletable", this) == false) ok = false; return false; }); return ok; }, 
						action  : function (NODE, TREE_OBJ) { $.each(NODE, function () { TREE_OBJ.remove(this); }); } 
					}
				]				
			},
			lang : {
				new_node    : '<%=WebManager.GetLabel("New Item",this).Replace("'", "\\'") %>',
				loading     : '<%=WebManager.GetLabel("Loading ...",this).Replace("'", "\\'") %>'
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
					var parentId = $( TREE_OBJ.parent( NODE ) ).attr('<%=ValueFieldName %>');
					var title = $(NODE).find('a').html();
					$.ajax({
						type: "POST", async: true,
						url: 'ProviderAjaxHandler.axd',
						data : { 
							provider : "<%=CreateOperationName %>", 
							context : JSON.stringify( { 
								parent : { <%=ValueFieldName %> :  parentId }, 
								<%=TextFieldName %> : title } ) 
						},
						success : function(res) { 
							var data = JSON.parse(res);
							$(NODE).attr('<%=ValueFieldName %>', data['<%=ValueFieldName %>']);						
						},
						error : function(err) { alert(err); }
					});						
				},
				onrename : function(NODE,LANG,TREE_OBJ,RB) { 
					var newTitle = $(NODE).find('a').html();
					$.ajax({
						type: "POST", async: true,
						url: 'ProviderAjaxHandler.axd',
						data : { 
							provider : "<%=RenameOperationName %>", 
							context : JSON.stringify( { 
								<%=ValueFieldName %> : $(NODE).attr('<%=ValueFieldName %>'), 
								<%=TextFieldName %> : newTitle } )
						},
						success : function(res) { 
							var data = JSON.parse(res);
							$(NODE).attr('<%=ValueFieldName %>', data['<%=ValueFieldName %>']);
						},
						error : function(err) { alert(err); }
					});	
				},
				onmove : function(NODE,REF_NODE,TYPE,TREE_OBJ,RB) { 
					alert( $(REF_NODE).attr('id') );
				},
				ondelete : function(NODE, TREE_OBJ,RB) { 
					$.ajax({
						type: "POST", async: true,
						url: 'ProviderAjaxHandler.axd',
						data : { provider : "<%=DeleteOperationName %>", context : JSON.stringify( { <%=ValueFieldName %> : $(NODE).attr('<%=ValueFieldName %>') } ) },
						success : function(res) { },
						error : function(err) { alert(err); }
					});
				},
				onrgtclk    : function(NODE, TREE_OBJ, EV) { TREE_OBJ.select_branch.call(TREE_OBJ, NODE); }
				/*onselect    : function(NODE,TREE_OBJ) { TREE_OBJ.toggle_branch.call(TREE_OBJ, NODE); TREE_OBJ.select_branch.call(TREE_OBJ, NODE); }*/
			}
		}
	);
	$('#<%=ClientID %> .addItem').click( function() {
		$.tree_reference('<%=ClientID %>jsTree').create(null,-1);
	});
});
</script>
