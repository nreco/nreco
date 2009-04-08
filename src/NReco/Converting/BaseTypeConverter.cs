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

namespace NReco.Converting {

	/// <summary>
	/// Simple type converter useful for conversions from one compatible interface to another.
	/// </summary>
	/// <typeparam name="T1">target type</typeparam>
	/// <typeparam name="T2">compatible with target type</typeparam>
	/// <typeparam name="DirectWr">from T1 to T2 wrapper type</typeparam>
	/// <typeparam name="ReverseWr">from T2 to T1 wrapper type</typeparam>
    public class BaseTypeConverter<T1, T2, DirectWr, ReverseWr> : ITypeConverter 
		where DirectWr:class 
		where ReverseWr: class
    {

		public BaseTypeConverter() {
		}

		protected bool IsConversion(Type fromType, Type toType, Type t1, Type t2) {
			return  fromType.GetInterface(t1.Name)==t1 &&
					toType==t2;
		}

		public virtual bool CanConvert(Type fromType, Type toType) {
			if (IsConversion(fromType,toType, typeof(T1), typeof(T2) ))
				return true;
			if (IsConversion(fromType,toType, typeof(T2), typeof(T1) ))
				return true;
			return false;
		}

		public virtual object Convert(object o, Type toType) {
			if (IsConversion(o.GetType(),toType, typeof(T1), typeof(T2) ))
				return Activator.CreateInstance( typeof(DirectWr), new object[] { o } );
			if (IsConversion(o.GetType(),toType, typeof(T2), typeof(T1) ))
				return Activator.CreateInstance( typeof(ReverseWr), new object[] { o } );
			throw new InvalidCastException();
		}

	}

}
