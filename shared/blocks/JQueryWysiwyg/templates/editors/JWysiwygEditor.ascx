<%@ Control Language="c#" AutoEventWireup="false" CodeFile="JWysiwygEditor.ascx.cs" Inherits="JWysiwygEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<asp:TextBox id="textbox" CssClass="jwysiwyg" runat="server" style="visibility:hidden;height:100%;margin:0px;" TextMode="multiline">
</asp:TextBox>
		
<script type="text/javascript">
jQuery(function(){
	var textArea = jQuery('#<%=textbox.ClientID %>');
	/*<xsl:if test="l:editor/l:jwysiwyg/@max-height='true' or l:editor/l:jwysiwyg/@max-height='1'">
		var delta = $(document).height()-$('body').height();
		if (delta@@gt;0)
			textArea.height( textArea.height()+ (delta*0.9) );
	</xsl:if>*/
	
	
	textArea.wysiwyg(
		{
			/*<xsl:if test="l:editor/l:jwysiwyg/@resize='1' or l:editor/l:jwysiwyg/@resize='true'">
			resizeOptions : true,
			</xsl:if>*/
			
			/*<xsl:if test="l:editor/l:jwysiwyg/@styletag='0' or l:editor/l:jwysiwyg/@styletag='false'">
			rmStyleTags : true,
			</xsl:if>*/
			
			
			
			/*placeholders : { 
				flash : '@@lt;%=VirtualPathUtility.AppendTrailingSlash(WebManager.BasePath) %@@gt;css/jwysiwyg/flash.jpg' 
			},*/
			initialContent : '',
			dialog:"jqueryui",
			messages: {
				nonSelection: <%=JsHelper.ToJsonString(WebManager.GetLabel("Select the text you wish to link")) %>
			},
			brIE : true,
			controls : {
					bold          : { visible : true},
					italic        : { visible : true },
					strikeThrough : { visible :  true },
					underline     : { visible :  true },

					justifyLeft   : { visible :  true },
					justifyCenter : { visible :  true },
					justifyRight  : { visible :  true},
					justifyFull   : { visible :  true },

					indent  : { visible :  true },
					outdent : { visible :  true },
					
					subscript   : { visible :  true },
					superscript : { visible :  true},
					
					undo : { visible :  false },
					redo : { visible :  false },
					
					insertOrderedList    : { visible :  true },
					insertUnorderedList  : { visible :  true },
					insertHorizontalRule : { visible :  true },
					
					colorpicker: {
						groupIndex: 9,
						visible: true,
						css: {
							"color": function (cssValue, Wysiwyg) {
								var document = Wysiwyg.innerDocument(),
									defaultTextareaColor = jQuery(document.body).css("color");

								if (cssValue !== defaultTextareaColor) {
									return true;
								}

								return false;
							}
						},
						exec: function() {
							if (jQuery.wysiwyg.controls.colorpicker) {
								jQuery.wysiwyg.controls.colorpicker.init(this);
							}
						},
						tooltip: "Colorpicker"
					},
					fullscreen: {
						groupIndex: 9,
						visible: true,
						exec: function () {
							if (jQuery.wysiwyg.fullscreen) {
								jQuery.wysiwyg.fullscreen.init(this);
							}
						},
						tooltip: "Fullscreen"
					},				
					
					<% if (!String.IsNullOrEmpty(CustomCreateLinkJsFunction)) { %>
					createLink : {
						visible : true,
						exec    : function()
						{
							var editor = this;
							var savedSelection;
							if (jQuery.browser.msie) {
								savedSelection = this.editorDoc.selection.createRange();
							}
							
							<%=CustomCreateLinkJsFunction %>( 
								function(linkUrl, linkTitle) {
									if (savedSelection!=null)
										savedSelection.select();
									jQuery('#<%=textbox.ClientID %>').wysiwyg('createLink', linkUrl, linkTitle);
								}
							);
						},
						tags : ['a']
					},								
					<% } %>
					
					<% if (!String.IsNullOrEmpty(CustomInsertImageJsFunction)) { %>
					insertImage : {
						visible : true,
						exec    : function()
						{
							var editor = this;
							var savedSelection;
							if (jQuery.browser.msie) {
								savedSelection = this.editorDoc.selection.createRange();
							}
							
							<%=CustomInsertImageJsFunction %>( 
								function(imgUrl) {
									if (savedSelection!=null)
										savedSelection.select();
									jQuery('#<%=textbox.ClientID %>').wysiwyg('insertImage', imgUrl);
								}
							);
						},
						tags : ['img']
					},						
					<% } %>
					
					cut   : { visible : true },
					copy  : { visible : true},
					paste : { visible : true },
					html : {visible : true},
					increaseFontSize : { visible : true },
					decreaseFontSize : { visible : true }
			}
		}
		
	);
	
	
	textArea.css("visibility","visible");
});
</script>
