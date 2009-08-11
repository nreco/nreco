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
using System.Reflection;

namespace NReco.Converting {
	
	public static class TypeHelper {

		public static Type FindGenericInterface(Type gType, Type gInterface) {
			// maybe gType is generic interface?
			if (gType.IsGenericType && gType.GetGenericTypeDefinition() == gInterface)
				return gType;

			string interfaceName = gInterface.Name;
			Type[] foundInterfaces = gType.FindInterfaces(Module.FilterTypeName, interfaceName);
			if (foundInterfaces != null)
				for (int i = 0; i < foundInterfaces.Length; i++) {
					Type deff = foundInterfaces[i].GetGenericTypeDefinition();
					if (deff == gInterface)
						return foundInterfaces[i];
				}
			return null;
		}

	}
}
