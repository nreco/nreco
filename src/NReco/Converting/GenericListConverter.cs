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
	/// Generic IList convertor interface
	/// </summary>
	public class GenericListConverter : BaseGenericTypeConverter {
		
		protected override bool CanConvertFromGeneric { get { return true; } }
		protected override bool CanConvertToGeneric { get { return true; } }
		protected override Type GenDefIType { get { return typeof(IList<>); } }
		protected override Type NonGenIType { get { return typeof(IList); } }

		public GenericListConverter() { }

		protected override object ConvertFromGeneric(object o, Type fromGenIType) {
			return CreateGenericWrapper(typeof(ListWrapper<>), fromGenIType, o);
		}
		protected override object ConvertToGeneric(object o, Type toGenIType) {
			Type[] listGArgs = toGenIType.GetGenericArguments();
			IList fromList = (IList)o;
			Array fromArr = Array.CreateInstance( listGArgs[0], fromList.Count);
			fromList.CopyTo(fromArr,0);
			Type genListType = typeof(List<>).MakeGenericType(listGArgs);
			return Activator.CreateInstance(genListType, fromArr);
		}


	}
}
