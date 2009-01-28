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
using System.Collections.Generic;
using System.Text;
using NReco.Providers;

namespace NReco.Converting {
	
	public class ProviderConverter : ITypeConverter {
		
		public bool CanConvert(Type fromType, Type toType) {
			if (!toType.IsGenericType || toType.GetGenericTypeDefinition() != typeof(IProvider<,>))
				return false;
			if (BaseGenericTypeConverter.FindGenericInterface(fromType, typeof(IProvider<,>)) == null)
				return false;
			return true;
		}

		public object Convert(object o, Type toType) {
			if (o==null) return null;
			if (!CanConvert(o.GetType(), toType))
				throw new InvalidCastException();

			Type wrDefType = typeof(ProviderWrapper<,,,>);
			Type[] fromArgs = BaseGenericTypeConverter.FindGenericInterface(o.GetType(), typeof(IProvider<,>)).GetGenericArguments();
			Type[] toArgs = toType.GetGenericArguments();
			Type wrType = wrDefType.MakeGenericType(fromArgs[0], fromArgs[1], toArgs[0], toArgs[1]);
			return Activator.CreateInstance(wrType, o);
		}

	}
}
