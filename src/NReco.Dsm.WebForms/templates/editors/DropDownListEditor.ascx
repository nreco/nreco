<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Dsm.WebForms.LookupEditorUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Implements Interface="System.Web.UI.ITextControl" %>
<%@ Implements Interface="System.Web.UI.IEditableTextControl" %>
<%@ Import Namespace="NReco.Dsm.WebForms" %>

<script runat="server" language="c#">
public string NotSelectedText { get; set; }
public string NotSelectedValue { get; set; }

object _SelectedValue = null;
public object SelectedValue {
	get {
		if (_SelectedValue != null) {
			return _SelectedValue;
		} else if (!Visible && ViewState["selectedValue"] != null) {
			return ViewState["selectedValue"];
		} else if (dropdownlist.SelectedIndex == 0 && NotSelectedText != null) {
			return NotSelectedValue;
		} else {
			return dropdownlist.SelectedValue;
		}
	}
	set {
		_SelectedValue = value;
		if (value == null)
			dropdownlist.SelectedValue = null;
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
		dropdownlist.DataBind();
	}
}

protected override void OnPreRender(EventArgs e) {
	if (TextChanged != null) {
		dropdownlist.AutoPostBack = true;
	}
	base.OnPreRender(e);
}

public override void DataBind() {
	base.DataBind();
	if (!Visible) {
		ViewState["selectedValue"] = _SelectedValue;
	}
	_SelectedValue = null;
}

protected IEnumerable GetDataSource() {
	IEnumerable dataSource = Visible && !String.IsNullOrEmpty(LookupName) ? GetLookupDataSource() : null;
	if (dataSource==null) return null;
	if (NotSelectedText != null) {
		var newDataSource = new List<object>(dataSource.Cast<object>());
		newDataSource.Insert(0, new NReco.Collections.DictionaryView(new Hashtable {
				{TextFieldName, AppContext.GetLabel(NotSelectedText,"DropDownListEditor") },
				{ValueFieldName, NotSelectedValue}
			}));
		dataSource = newDataSource;
	}
	return dataSource;
}
</script>

<span id="<%=ClientID %>" class="dropDownListEditor">
	<NRecoWebForms:DropDownList runat="server" id="dropdownlist" 
		CssClass="form-control"
		SelectedValue='<%# SelectedValue %>'
		DataSource='<%# GetDataSource() %>'
		DataValueField="<%# ValueFieldName %>"
		DataTextField="<%# TextFieldName %>"
		OnSelectedIndexChanged="HandleSelectedIndexChanged">
	</NRecoWebForms:DropDownList>
</span>