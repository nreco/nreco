#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008,2009 Vitaliy Fedorchenko
 * Distributed under the LGPL licence
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#endregion

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
	public TimeSpan DefaultValue { get; set; }
	public int HourStep { get; set; }
	public int MinuteStep { get; set; }
	public int SecondStep { get; set; }
	
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
			if (AssertHelper.IsFuzzyEmpty(value) ) {
				timeValue.Value = String.Empty;
			} else {
				timeValue.Value = GetFormattedTime( TimeSpan.FromSeconds( Convert.ToInt64( value ) ) );
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
		HourStep = 1;
		MinuteStep = 1;
		SecondStep = 1;
		DefaultValue = TimeSpan.Zero;
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
