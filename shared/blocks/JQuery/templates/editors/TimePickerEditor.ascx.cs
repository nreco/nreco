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

[ValidationProperty("StringValue")]
public partial class TimePickerEditor : NReco.Web.ActionUserControl {
	
	public string JsScriptName { get; set; }
	public bool RegisterJs { get; set; }
	public bool SecondsSelection { get; set; }
	
	public object TimeSpanValue {
		get {
			if (String.IsNullOrEmpty( timeValue.Value))
				return null;
			return TimeSpan.Parse(timeValue.Value);
		}
		set {
			timeValue.Value = value is TimeSpan ? GetFormattedTime( (TimeSpan)value ) : String.Empty;
		}
	}
	
	public object SecondsValue {
		get { 
			if (String.IsNullOrEmpty( timeValue.Value))
				return null;
			return (int)TimeSpan.Parse(timeValue.Value).TotalSeconds;
		}
		set {
			if (!(value is int)) {
				timeValue.Value = String.Empty;
			} else {
				timeValue.Value = GetFormattedTime( TimeSpan.FromSeconds( (int) value ) );
			}
		}
	}
	
	public object StringValue {
		get { 
			if (String.IsNullOrEmpty( timeValue.Value))
				return null;
			return GetFormattedTime(TimeSpan.Parse(timeValue.Value) );
		}
		set {
			if (String.IsNullOrEmpty(value as string)) {
				timeValue.Value = String.Empty;
			} else {
				timeValue.Value = GetFormattedTime( TimeSpan.Parse(value as string) );
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
		return String.Format( GetFormatStr(), val.Hours, val.Minutes, val.Seconds );
	}
	
	protected string GetFormatStr() {
		return SecondsSelection ? "{0:00}:{1:00}:{2:00}" : "{0:00}:{1:00}";
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			JsHelper.RegisterJsFile(Page,JsScriptName);
		}		
	}

}
