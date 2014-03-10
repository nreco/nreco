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
	/// Abstract user data storage interface.
	/// </summary>
	public interface IUserStorage {
		void Create(User user);
		User Load(User sampleUser);
		IEnumerable<User> LoadAll(User sampleUser, int pageIndex, int pageSize, out int totalRecords);
		bool Update(User user);
		bool Delete(User user);

	}

}
