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
using NI.Vfs;

[ValidationProperty("Value")]
public partial class SingleFileEditor : System.Web.UI.UserControl {
	
	public string Value {
		get {
			return filePath.Value;
		}
		set {
			filePath.Value = value;
		}
	}
	
	public bool ReadOnly { get; set; }
	
	public bool AllowOverwrite { get; set; }
	
	public bool ClearFormOnUpload { get; set; }
	
	public string FileSystemName { get; set; }
	
	public string BasePath { get; set; }
	
	protected IFileSystem FileSystem {
		get {
			return WebManager.GetService<IFileSystem>(FileSystemName);
		}
	}
	
	public SingleFileEditor() {
		ReadOnly = false;
		AllowOverwrite = false;
		ClearFormOnUpload = true;
	}
	
}
