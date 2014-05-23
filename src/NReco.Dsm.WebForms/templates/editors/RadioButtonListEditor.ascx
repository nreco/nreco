<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Dsm.WebForms.LookupEditorUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Implements Interface="System.Web.UI.ITextControl" %>
<%@ Implements Interface="System.Web.UI.IEditableTextControl" %>

<script runat="server" language="c#">
public string NotSelectedText { get; set; }
public string NotSelectedValue { get; set; }
public RepeatDirection RepeatDirection { get; set; }

object _SelectedValue = null;

public object SelectedValue {
	get {
		if (_SelectedValue != null) {
			return _SelectedValue;
		} else if (!Visible && ViewState["selectedValue"] != null) {
			return ViewState["selectedValue"];
		} else {
			if (radiobuttonlist.SelectedIndex == 0 && NotSelectedText != null)
				return NotSelectedValue;
			return radiobuttonlist.SelectedValue;
		}
	}
	set {
		_SelectedValue = value;
		if (value == null)
			radiobuttonlist.SelectedValue = null;
	}
}

public override object ValidationValue { get { return SelectedValue; } }

string ITextControl.Text {
	get { return SelectedValue as string; }
	set { SelectedValue = value; }
}

public event EventHandler TextChanged;

public string DataContextControl { get; set; }

protected void HandleSelectedIndexChanged(object sender, EventArgs e) {
	if (TextChanged != null)
		TextChanged(this, EventArgs.Empty);
}

protected override void DependentFromControlChangedHandler(object sender, EventArgs e) {
	if (DataContextControl != null && (NamingContainer.FindControl(DataContextControl) as DataContextHolder) != null) {
		LookupDataContext = ((DataContextHolder)NamingContainer.FindControl(DataContextControl)).GetDataContext();
		radiobuttonlist.DataBind();
	}
}

protected override void OnPreRender(EventArgs e) {
	if (TextChanged != null) {
		radiobuttonlist.AutoPostBack = true;
	}
	base.OnPreRender(e);
}

protected IEnumerable GetDataSource() {
	IEnumerable dataSource = Visible && !String.IsNullOrEmpty(LookupName) ? GetLookupDataSource() : null;
	if (dataSource == null) return null;
	if (NotSelectedText != null) {
		var newDataSource = new List<object>(dataSource.Cast<object>());
		newDataSource.Insert(0, new NReco.Collections.DictionaryView(new Hashtable {
				{TextFieldName, NotSelectedText},
				{ValueFieldName, NotSelectedValue}
			}));
		dataSource = newDataSource;
	}
	return dataSource;
}

public override void DataBind() {
	radiobuttonlist.SelectedValue = null;
	base.DataBind();
	// if editor is invisible, just save 
	if (!Visible) {
		ViewState["selectedValue"] = _SelectedValue;
	} else {
		if (_SelectedValue != null)
			ControlUtils.SetSelectedItems( radiobuttonlist, new string[] { Convert.ToString(_SelectedValue) });
	}
	_SelectedValue = null;
}
</script>

<span id="<%=ClientID %>" class="radioButtonListEditor">
	<asp:RadioButtonList runat="server" id="radiobuttonlist" 
		RepeatLayout="Flow"
		RepeatDirection='<%# RepeatDirection %>'
		DataSource='<%# GetDataSource() %>'
		DataValueField="<%# ValueFieldName %>"
		DataTextField="<%# TextFieldName %>"
		OnSelectedIndexChanged="HandleSelectedIndexChanged">
	</asp:RadioButtonList>
</span>