#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2011 Vitaliy Fedorchenko
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
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;

using NReco;
using NReco.Logging;
using NReco.Collections;
using NReco.Converting;
using NReco.Web;
using NReco.Web.Site;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

public abstract class DataContextView : ActionUserControl, IDataContextAware {
	
	bool _UseSessionDataContext = false;
	public bool UseSessionDataContext { 
		get { return _UseSessionDataContext; }
		set { _UseSessionDataContext = value; }
	}
	
	bool _UseViewstateDataContext = true;
	public bool UseViewstateDataContext { 
		get { return _UseViewstateDataContext; }
		set { _UseViewstateDataContext = value;	}
	}
	
	protected string SessionDataContextKey { 
		get {
			return String.Format("dataContext#{0}#{1}",Request.Url.AbsolutePath,ClientID);
		}
	}
	
	private IDictionary<string,object> _DataContext = null;
	public IDictionary<string,object> DataContext {
		get { 
			if (UseSessionDataContext) {
				var dataCntx = Session[SessionDataContextKey] as IDictionary<string,object>;
				if (dataCntx==null) {
					dataCntx = new Dictionary<string,object>();
					Session[SessionDataContextKey] = dataCntx;
				}				
				return dataCntx;
			} else {
				if (_DataContext==null) {
					_DataContext = new Dictionary<string,object>();
				}
				return _DataContext; 
			}
		}
		set { 
			if (UseSessionDataContext) {
				Session[SessionDataContextKey] = value;
			} else {
				_DataContext = value;
			}
		}
	}
	
	public DataContextView() {
		UseSessionDataContext = false;
	}
	
	// if we initialized datacontext *before* viewstate load -> preserve those values
	protected override void LoadViewState(object savedState) {
		if ( (savedState is object[]) && !UseSessionDataContext && UseViewstateDataContext) {
			var savedStateArr = (object[])savedState;
			base.LoadViewState(savedStateArr[0]);
			if (savedStateArr[1] is IDictionary<string, object>) {
				var newContext = (IDictionary<string, object>)savedStateArr[1];
				if (_DataContext != null) {
					foreach (var d in _DataContext) {
						newContext[d.Key] = d.Value;
					}
				} 
				_DataContext = newContext;
			}
		} else {
			base.LoadViewState(savedState);
		}
	}
	protected override object SaveViewState() {
		if (_DataContext != null && !UseSessionDataContext && UseViewstateDataContext) {
			object baseState = base.SaveViewState();
			object[] allStates = new object[2];
			allStates[0] = baseState;
			allStates[1] = _DataContext;
			return allStates;
		} else {
			return base.SaveViewState();
		}
	}
}