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
			markupSet:  [ 	
				{name:'Heading 1', key:'1', openWith:'<h1(!( class="[![Class]!]")!)>', closeWith:'</h1>', placeHolder:'<%=WebManager.GetLabel("Header 1",this) %>', className: "markItUpButtonH1" },
				{name:'Heading 2', key:'2', openWith:'<h2(!( class="[![Class]!]")!)>', closeWith:'</h2>', placeHolder:'<%=WebManager.GetLabel("Header 2",this) %>', className: "markItUpButtonH2" },
				{name:'Heading 3', key:'3', openWith:'<h3(!( class="[![Class]!]")!)>', closeWith:'</h3>', placeHolder:'<%=WebManager.GetLabel("Header 3",this) %>', className: "markItUpButtonH3" },
				{separator:'---------------' },
				{name:'Bold', key:'B', openWith:'(!(<strong>|!|<b>)!)', closeWith:'(!(</strong>|!|</b>)!)', className: "markItUpButtonBold" },
				{name:'Italic', key:'I', openWith:'(!(<em>|!|<i>)!)', closeWith:'(!(</em>|!|</i>)!)', className: "markItUpButtonItalic"  },
				{name:'Stroke through', key:'S', openWith:'<del>', closeWith:'</del>', className: "markItUpButtonStroke" },
				{separator:'---------------' },
				{name:'Picture', className: "markItUpButtonInsPicture", key:'P', replaceWith:'<img src="[![Source:!:http://]!]" alt="[![Alternative text]!]" />' },
				{name:'Link', className: "markItUpButtonInsLink", key:'L', openWith:'<a href="[![Link:!:http://]!]"(!( title="[![Title]!]")!)>', closeWith:'</a>', placeHolder:'Your text to link...' },
				{separator:'---------------' },
				{name:'Line Break', openWith:'<br/>', className: "markItUpButtonLineBreak"  },
				{name:'Whitepace', openWith:'@@amp;nbsp;', className: "markItUpButtonWhitespace"  },
				{name:'Clean', className: "markItUpButtonClean", replaceWith:function(markitup) { return markitup.selection.replace(/<(.*?)>/g, "") } },		
				{name:'Preview', className:'preview',  call:'preview'}
			]
		}
	);	
	
});
</script>
	