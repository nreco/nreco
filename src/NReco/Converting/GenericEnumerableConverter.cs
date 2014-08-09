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
using System.Text;

using NReco.Collections;

namespace NReco.Converting {

	/// <summary>
	/// Generic IEnumerable convertor interface
	/// </summary>
	public class GenericEnumerableConverter : BaseGenericTypeConverter {
		
		protected override bool CanConvertFromGeneric { get { return false; } }
		protected override bool CanConvertToGeneric { get { return true; } }
		protected override Type GenDefIType { get { return typeof(IEnumerable<>); } }
		protected override Type NonGenIType { get { return typeof(IEnumerable); } }

		public GenericEnumerableConverter() { }

		protected override object ConvertFromGeneric(object o, Type fromGenIType) {
			throw new NotSupportedException();
		}

		protected override object ConvertToGeneric(object o, Type toGenIType) {
			Type[] collGArgs = toGenIType.GetGenericArguments();
			IEnumerable fromEnum = (IEnumerable)o;

			var resList = new ArrayList();
			foreach (var elem in fromEnum)
				resList.Add(ConvertManager.ChangeType(elem, collGArgs[0]));
			return resList.ToArray(collGArgs[0]);
		}


	}
}
