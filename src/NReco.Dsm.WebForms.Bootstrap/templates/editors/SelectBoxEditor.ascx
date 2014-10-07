<%@ Control Language="c#" Inherits="NReco.Dsm.WebForms.EditorUserControl" AutoEventWireup="false" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Implements Interface="System.Web.UI.ITextControl" %>
<%@ Implements Interface="System.Web.UI.IEditableTextControl" %>
<%@ Import Namespace="NI.Ioc" %>
<%@ Import Namespace="NReco.Application.Web" %>
<%@ Import Namespace="NReco.Dsm.WebForms" %>
<script runat="server" language="c#">

public override object ValidationValue { get { return Text; } }

public string DataProvider { get; set; }
public string TextFieldName { get; set; }
public string ValueFieldName { get; set; }

public bool Multivalue { get; set; }

public string NotSelectedText { get; set; }
public object NotSelectedValue { get; set; }

public event EventHandler TextChanged;
public bool AutoPostBack { get; set; }

public string DataContextControl { get; set; }
public object ProviderDataContext { get; set; }

public object Value {
	get {
		if (Multivalue) {
			return Text.Split(new char[]{','}, StringSplitOptions.RemoveEmptyEntries);
		}
		return String.IsNullOrEmpty(Text) ? NotSelectedValue : Text;
	}
	set {
		if (Multivalue) {
			var values = value is IEnumerable && !(value is string) ? 
				((IEnumerable)value).Cast<object>().Select(v => Convert.ToString(v)).ToArray() : new string[0];
			Text = String.Join(",", values);
		} else {
			Text = Convert.ToString(value);
		}
	}
}

public string Text {
	get {
		return selectedValue.Value;
	}
	set {
		selectedValue.Value = value;
	}
}

protected override void OnPreRender(EventArgs e) {
	if (TextChanged != null) {
		AutoPostBack = true;
	}
	valueChangeBtn.Visible = AutoPostBack;
	base.OnPreRender(e);
}

protected void HandleValueChanged(object sender, EventArgs e) {
	if (TextChanged != null)
		TextChanged(this, EventArgs.Empty);
}

protected override void DependentFromControlChangedHandler(object sender, EventArgs e) {
	if (DataContextControl != null && (NamingContainer.FindControl(DataContextControl) as DataContextHolder) != null) {
		ProviderDataContext = ((DataContextHolder)NamingContainer.FindControl(DataContextControl)).GetDataContext();
		prvContext.DataBind();
	}
}

protected IDictionary<string,string> GetSelectedText() {
	var res = new Dictionary<string,string>();

	if (!String.IsNullOrEmpty(Text)) { 
		var providerContext = new Dictionary<string,object>();
		providerContext["value"] = Value;
		var prv = AppContext.ComponentFactory.GetComponent<Func<IDictionary<string,object>,IEnumerable>>(DataProvider);
		var matchedData = NReco.Dsm.WebForms.ControlUtils.WrapWithDictionaryView( prv(providerContext) );
	
		foreach (var entry in matchedData) {
			var entryValue = Convert.ToString( DataBinder.Eval(entry, ValueFieldName) );
			var entryText = Convert.ToString( DataBinder.Eval(entry, TextFieldName) );
			res[entryValue] = entryText;
		}
	}
	return res;
}
</script>
<span id="<%=ClientID %>" class="selectBoxEditor">
	<input type="hidden" id="selectedValue" runat="server" class="form-control" autocomplete="off"/>
	<input type="hidden" id="prvContext" runat="server" autocomplete="off" value='<%# JsUtils.ToJsonString(ProviderDataContext) %>'/>
	<NRecoWebForms:LinkButton id="valueChangeBtn" CausesValidation="false" runat="server" OnClick="HandleValueChanged" style="display:none;"/>
	<NRecoWebForms:JavaScriptHolder runat="server">
		$(function () {
			var pageSize = 10;
			var dataValueField = '<%=ValueFieldName %>';
			var dataTextField = '<%=TextFieldName %>';
			var selectedText = <%=NReco.Dsm.WebForms.JsUtils.ToJsonString(GetSelectedText()) %>;
			var selectedInput = $('#<%=selectedValue.ClientID %>');
			var prvContextInput = $('#<%=prvContext.ClientID %>');
			selectedInput.select2({
				minimumInputLength: 0,
				allowClear: true,
				multiple : <%=Multivalue.ToString().ToLower() %>,
				placeholder: <%=NReco.Dsm.WebForms.JsUtils.ToJsonString(AppContext.GetLabel(NotSelectedText??" ")) %>, 
				ajax: {
					url: '<%=AppContext.BaseUrlPath %>webforms/api/selectbox',
					dataType: 'json',
					quietMillis: 200,
					data: function (term, page) {
						var selectBoxContext = {
							provider : '<%=DataProvider %>',
							q: term,
							limit: pageSize+1, // page size
							start: (page-1)*pageSize, // page number
						};
						var prvContextJson = prvContextInput.val();
						if (prvContextJson.length>0 && prvContextJson!="null")
							selectBoxContext.providerContext = prvContextJson;
						return selectBoxContext;
					},
					results: function (res, page) {
						var more = res.data.length>pageSize;
						var rs = [];
						for (var rIdx=0; rIdx<res.data.length; rIdx++) {
							rs.push({'id':res.data[rIdx][dataValueField], 'text' : res.data[rIdx][dataTextField] });
						}
						return { results: rs, more: more };
					}
				},				
				initSelection: function (element, callback) {
					var data = [];
					$(element.val().split(",")).each(function () {
						var valText = selectedText[this];
						if (this && valText) {
							data.push({'id': this, 'text': valText});
						}
					});
					callback(data.length>0 ? (<%=Multivalue.ToString().ToLower() %>?data:data[0]) : {'id':'','text':''});
				}
			});
			<% if (AutoPostBack) { %>
			selectedInput.change( function(e) {
				setTimeout(function() {
					<%=Page.ClientScript.GetPostBackEventReference(valueChangeBtn,"") %>;
				},10);
			});
			<% } %>
		});
	</NRecoWebForms:JavaScriptHolder>
</span>