<%@ Control Language="c#" Inherits="NReco.Dsm.WebForms.EditorUserControl" AutoEventWireup="false" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Implements Interface="System.Web.UI.ITextControl" %>
<script runat="server" language="c#">
public bool EmptyIsNull { get; set; }

public Unit Width {
	get { return textbox.Width; }
	set { textbox.Width = value; }
}

public string PrefixText { get; set; }
public string SuffixText { get; set; }

public string Format { get; set; }

public TypeCode DataType { get; set; }

public override object ValidationValue { get { return Text; } }

public object Value {
	get {
		var text = Text;
		if (text==null)
			return null;
		if (DataType!=TypeCode.String) {
			try {
				return Convert.ChangeType(text, DataType);
			} catch {
				// try invariant culture
				try {
					return Convert.ChangeType(text, DataType, System.Globalization.CultureInfo.InvariantCulture);
				} catch {
					return null;
				}
			}
		}
		return text;	
	}
	set {
		Text = Format!=null ? String.Format(Format, value) : Convert.ToString(value);
	}
}

public string Text {
	get {
		if (EmptyIsNull && String.IsNullOrEmpty(textbox.Text))
			return null;
		return textbox.Text;
	}
	set {
		textbox.Text = value;
	}
}
</script>
<span id="<%=ClientID %>" class="textBoxEditor <%# String.IsNullOrEmpty(PrefixText) && String.IsNullOrEmpty(SuffixText) ? "" : "input-group"  %>">
<%# String.IsNullOrEmpty(PrefixText) ? String.Empty : String.Format("<span class=\"input-group-addon\">{0}</span>",PrefixText) %>
<asp:TextBox id="textbox" CssClass="form-control" runat="server"/>
<%# String.IsNullOrEmpty(SuffixText) ? String.Empty : String.Format("<span class=\"input-group-addon\">{0}</span>",SuffixText) %>
</span>