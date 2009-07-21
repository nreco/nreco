using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;

using NReco;
using NReco.Converting;
using NReco.Web;
using NReco.Web.Site;
using NReco.Web.Site.Controls;
using NReco.Web.Site.Security;

[ValidationProperty("Value")]
public partial class PasswordTextBoxEditor : System.Web.UI.UserControl {
	
	public string Value {
		get {
			if (String.IsNullOrEmpty(textbox.Text))
				return ViewState["passwordValue"] as string;
			return String.IsNullOrEmpty(PasswordEncrypterName) ? textbox.Text : PasswordEncrypter.Encrypt( textbox.Text );
		}
		set {
			ViewState["passwordValue"] = value;
			textbox.Text = String.Empty;
		}
	}
	
	public string PasswordEncrypterName { get; set; }
	
	protected IPasswordEncrypter PasswordEncrypter {
		get {
			return WebManager.GetService<IPasswordEncrypter>(PasswordEncrypterName);
		}
	}
	
}
