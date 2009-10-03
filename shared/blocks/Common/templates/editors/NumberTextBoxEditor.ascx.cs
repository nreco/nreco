using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;

[ValidationProperty("Value")]
public partial class NumberTextBoxEditor : System.Web.UI.UserControl, ITextControl {
	
	public string Format { get; set; }
	
	public TypeCode Type { get; set; }
	
	public object Value {
		get {
			if (String.IsNullOrEmpty(textbox.Text))
				return null;
			return Convert.ChangeType( textbox.Text, Type);
		}
		set {
			textbox.Text = String.Format(Format,value);
		}
	}
	
	public string Text {
		get {
			return textbox.Text;
		}
		set { textbox.Text = value; }
	}
		
	public NumberTextBoxEditor() {
		Format = "{0}";
		Type = TypeCode.Int32;
	}
	
}
