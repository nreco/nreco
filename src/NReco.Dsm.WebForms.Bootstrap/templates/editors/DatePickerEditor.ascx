<%@ Control Language="c#" Inherits="NReco.Dsm.WebForms.EditorUserControl" AutoEventWireup="false" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Implements Interface="System.Web.UI.ITextControl" %>
<script runat="server" language="c#">
public string Format { get; set; }

public override object ValidationValue { get { return Value; } }

public object Value {
	get {
		var text = Text;
		if (String.IsNullOrEmpty(text))
			return null;
		DateTime dt;
		if (DateTime.TryParse(text, out dt))
			return dt;
		if (DateTime.TryParse(text, System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out dt ))
			return dt;
		return null;
	}
	set {
		Text = Format!=null ? String.Format(Format, value) : Convert.ToString(value);
	}
}

public string Text {
	get {
		return textbox.Text;
	}
	set {
		textbox.Text = value;
	}
}
</script>
<span id="<%=ClientID %>" class="datePickerEditor input-group date">
<asp:TextBox id="textbox" CssClass="form-control" runat="server"/>
	<span class="input-group-addon"><i class="glyphicon glyphicon-th"></i></span>
	<NRecoWebForms:JavaScriptHolder runat="server">
		$(function () {
			$('#<%=ClientID %>').datepicker({});
		});
	</NRecoWebForms:JavaScriptHolder>
</span>