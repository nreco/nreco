using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;

[ValidationProperty("Text")]
public partial class TextBoxEditor : System.Web.UI.UserControl, ITextControl {
	
	public bool EmptyIsNull { get; set; }
	
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

	
}
