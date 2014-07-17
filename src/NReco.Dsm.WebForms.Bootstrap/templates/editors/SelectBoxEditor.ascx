<%@ Control Language="c#" Inherits="NReco.Dsm.WebForms.EditorUserControl" AutoEventWireup="false" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Implements Interface="System.Web.UI.ITextControl" %>
<%@ Import Namespace="NI.Ioc" %>
<%@ Import Namespace="NReco.Application.Web" %>
<script runat="server" language="c#">

public override object ValidationValue { get { return Text; } }

public string DataProvider { get; set; }
public string TextFieldName { get; set; }
public string ValueFieldName { get; set; }

public bool Multivalue { get; set; }

public string NotSelectedText { get; set; }

public object Value {
	get {
		if (Multivalue) {
			return Text.Split(new char[]{','}, StringSplitOptions.RemoveEmptyEntries);
		}
		return Text;
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
	<input type="hidden" id="selectedValue" runat="server" class="form-control" />

	<NRecoWebForms:JavaScriptHolder runat="server">
		$(function () {
			var pageSize = 10;
			var dataValueField = '<%=ValueFieldName %>';
			var dataTextField = '<%=TextFieldName %>';
			var selectedText = <%=NReco.Dsm.WebForms.JsUtils.ToJsonString(GetSelectedText()) %>;
			$('#<%=selectedValue.ClientID %>').select2({
				minimumInputLength: 0,
				allowClear: true,
				multiple : <%=Multivalue.ToString().ToLower() %>,
				placeholder: <%=NReco.Dsm.WebForms.JsUtils.ToJsonString(AppContext.GetLabel(NotSelectedText??" ")) %>, 
				ajax: {
					url: '<%=AppContext.BaseUrlPath %>webforms/api/selectbox',
					dataType: 'json',
					quietMillis: 200,
					data: function (term, page) {
						return {
							provider : '<%=DataProvider %>',
							q: term,
							limit: pageSize+1, // page size
							start: (page-1)*pageSize, // page number
						};
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
					callback(data.length>0 ? data[0] : {'id':'','text':''});
				}
			});
		});
	</NRecoWebForms:JavaScriptHolder>
</span>