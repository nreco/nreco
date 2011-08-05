<%@ Control Language="c#" AutoEventWireup="false" CodeFile="JQueryMarkItUpEditor.ascx.cs" Inherits="JQueryMarkItUpEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<asp:TextBox id="textbox" runat="server" Text='<%# Text %>' TextMode="multiline" Rows='<%# Rows %>'></asp:TextBox>

<script language="javascript">
jQuery(function(){
	
	jQuery('#<%=textbox.ClientID %>').markItUp(
		{	
			root : 'js/markitup/',
			onShiftEnter:  	{keepDefault:false, replaceWith:'<br/>\n'},
			onCtrlEnter:  	{keepDefault:false, openWith:'\n<p>', closeWith:'</p>'},
			onTab:    		{keepDefault:false, replaceWith:'    '},
			previewAutoRefresh : true,
			markupSet:  [ 				
				{name:'Heading 1', key:'1', openBlockWith:'<h1(!( class="[![Class]!]")!)>', closeBlockWith:'</h1>', placeHolder:'<%=WebManager.GetLabel("Header 1",this) %>', className: "markItUpButtonH1" },
				{name:'Heading 2', key:'2', openBlockWith:'<h2(!( class="[![Class]!]")!)>', closeBlockWith:'</h2>', placeHolder:'<%=WebManager.GetLabel("Header 2",this) %>', className: "markItUpButtonH2" },
				{name:'Heading 3', key:'3', openBlockWith:'<h3(!( class="[![Class]!]")!)>', closeBlockWith:'</h3>', placeHolder:'<%=WebManager.GetLabel("Header 3",this) %>', className: "markItUpButtonH3" },
				{name:'Paragraph', className : "markItUpButtonParagraph", openBlockWith:'<p(!( class="[![Class]!]")!)>', closeBlockWith:'</p>' }, 
				{separator:'---------------' },
				{name:'Bold', key:'B', openBlockWith:'(!(<strong>|!|<b>)!)', closeBlockWith:'(!(</strong>|!|</b>)!)', className: "markItUpButtonBold" },
				{name:'Italic', key:'I', openBlockWith:'(!(<em>|!|<i>)!)', closeBlockWith:'(!(</em>|!|</i>)!)', className: "markItUpButtonItalic"  },
				{name:'Stroke through', key:'S', openBlockWith:'<del>', closeBlockWith:'</del>', className: "markItUpButtonStroke" },
				{separator:'---------------' },
				{name:'Ul', className: "markItUpButtonListBullet",  openBlockWith:"<ul>\n",  openWith:"<li>", closeWith:"</li>", closeBlockWith:"</ul>\n"  },
				{name:'Ol', className : "markItUpButtonListNumeric", openBlockWith:"<ol>\n",  openWith:"<li>", closeWith:"</li>", closeBlockWith:"</ol>\n" },
				{name:'Li', className : "markItUpButtonListItem", openWith:'<li>', closeWith:'</li>' },				
				{separator:'---------------' },
				{name:'Picture', className: "markItUpButtonInsPicture", key:'P', replaceWith:'<img src="[![Source:!:http://]!]" alt="[![Alternative text]!]" />' },
				{name:'Link', className: "markItUpButtonInsLink", key:'L', openWith:'<a href="[![Link:!:http://]!]"(!( title="[![Title]!]")!)>', closeWith:'</a>', placeHolder:'Your text to link...' },
				{separator:'---------------' },
				{name:'Clean', className:'clean', replaceWith:function(markitup) { return markitup.selection.replace(/<(.*?)>/g, "") } }, 
				{name:'Preview', className:'preview',  call:'preview'}
			]
		}
	);	
	
});
</script>
	