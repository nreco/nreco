#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2014 Vitaliy Fedorchenko
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

namespace NReco.Application.Web.Security {
	
	/// <summary>
	/// Abstract user roles data storage interface.
	/// </summary>
	public interface IUserRoleStorage {
		void Add(string userName, string roleName);
		bool Exists(string userName, string roleName);
		bool Remove(string userName, string roleName);
		string[] GetUsers(string roleName);
		string[] GetRoles(string userName);
	}

}
