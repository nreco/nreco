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
using System.Text;
using NReco.Composition;

namespace NReco.Converting {
	
	public class OperationConverter : ITypeConverter {
		
		public bool CanConvert(Type fromType, Type toType) {
			if (!toType.IsGenericType || toType.GetGenericTypeDefinition() != typeof(IOperation<>))
				return false;
			if (BaseGenericTypeConverter.FindGenericInterface(fromType, typeof(IOperation<>)) == null)
				return false;
			return true;
		}

		public object Convert(object o, Type toType) {
			if (o==null) return null;
			if (!CanConvert(o.GetType(), toType))
				throw new InvalidCastException();

			Type wrDefType = typeof(OperationWrapper<,>);
			Type[] fromArgs = BaseGenericTypeConverter.FindGenericInterface(o.GetType(), typeof(IOperation<>)).GetGenericArguments();
			Type[] toArgs = toType.GetGenericArguments();
			Type wrType = wrDefType.MakeGenericType(fromArgs[0],toArgs[0]);
			return Activator.CreateInstance(wrType, o);
		}

	}
}
