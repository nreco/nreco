using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;
using System.Globalization;

using NReco;
using NReco.Web;
using NReco.Web.Site;

[ValidationProperty("ObjectValue")]
public partial class TimePickerEditor : NReco.Web.ActionUserControl {
	
	public string JsScriptName { get; set; }
	public bool RegisterJs { get; set; }
	int? Seconds = 0;
	
	public TimeSpan TimeSpanValue {
		get {
			return String.IsNullOrEmpty( timeValue.Value) ? new TimeSpan(0,0,0) : TimeSpan.Parse(timeValue.Value);
		}
		set {
			timeValue.Value = GetFormattedTime( value );
		}
	}
	
	public object ObjectValue {
		get { 
			if (String.IsNullOrEmpty( timeValue.Value))
				return null;
			return (int)TimeSpan.Parse(timeValue.Value).TotalSeconds;
		}
		set {
			if (value==null || value==DBNull.Value) {
				timeValue.Value = String.Empty;
			} else if (value is int) {
				timeValue.Value = GetFormattedTime( TimeSpan.FromSeconds((int)value) );
			} else if (value is string) {
				timeValue.Value = GetFormattedTime( TimeSpan.Parse( (string)value) );
			}
		}
	}
	
	public TimePickerEditor() {
		JsScriptName = "js/jquery.timeentry.pack.js";
		RegisterJs = true;
	}
	
	/*protected string GetDateJsPattern() {
		string s = CultureInfo.CurrentCulture.DateTimeFormat.ShortDatePattern.ToLower();
		if (s.IndexOf('m') == s.LastIndexOf('m')) s.Replace("m", "mm");
		if (s.IndexOf('d') == s.LastIndexOf('d')) s.Replace("d", "dd");
		return s.Replace("yyyy","yy");
    }*/

	protected string GetFormattedTime(TimeSpan val) {
		return String.Format("{0:00}:{1:00}", val.Hours, val.Minutes );
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			JsHelper.RegisterJsFile(Page,JsScriptName);
		}		
	}

}
