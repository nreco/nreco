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
using System.Collections;
using System.Text;

using ognl;
using NReco.OGNL.Helpers;

namespace NReco.OGNL {
	
	public class HelpersClassResolver : ClassResolver {
		ClassResolver UnderlyingResolver;

		static IDictionary<string, Type> helperClasses = 
					new Dictionary<string, Type>() {
						{"datarow", typeof(DataRow)},
						{"regex", typeof(Regex)}
					};

		public HelpersClassResolver(ClassResolver underlyingResolver) {
			UnderlyingResolver = underlyingResolver;
		}

		public Type classForName(string className, IDictionary context) {
			var classNameLower = className.ToLower();
			if (helperClasses.ContainsKey(classNameLower)) {
				return helperClasses[classNameLower];
			}
			return UnderlyingResolver.classForName(className, context);
		}

	}
}
