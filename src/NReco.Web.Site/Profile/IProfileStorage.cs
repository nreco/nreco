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
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using System.Web.Profile;

namespace NReco.Web.Site.Profile {
	
	/// <summary>
	/// Abstract profile data storage interface.
	/// </summary>
	public interface IProfileStorage {
		bool Delete(string userName);
		SettingsPropertyValueCollection LoadValues(string userName, SettingsPropertyCollection props);
		void SaveValues(string userName, SettingsPropertyValueCollection values);
	}

}
