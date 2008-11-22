#region License
/*
 * NReco library (http://code.google.com/p/nreco/)
 * Copyright 2008 Vitaliy Fedorchenko
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

namespace NReco.Converters {

	/// <summary>
	/// Generic ICollection convertor interface
	/// </summary>
	public class GenericCollectionConverter : BaseGenericTypeConverter {
		
		protected override bool CanConvertFromGeneric { get { return true; } }
		protected override bool CanConvertToGeneric { get { return true; } }
		protected override Type GenDefIType { get { return typeof(ICollection<>); } }
		protected override Type NonGenIType { get { return typeof(ICollection); } }

		public GenericCollectionConverter() { }

		protected override object ConvertFromGeneric(object o, Type fromGenIType) {
			return CreateGenericWrapper(typeof(CollectionWrapper<>), fromGenIType, o);
		}
		protected override object ConvertToGeneric(object o, Type toGenIType) {
			Type[] collGArgs = toGenIType.GetGenericArguments();
			ICollection fromColl = (ICollection)o;
			Array fromArr = Array.CreateInstance( collGArgs[0], fromColl.Count);
			fromColl.CopyTo(fromArr,0);
			return fromArr; // typed array implements ICollection<>
		}


	}
}
