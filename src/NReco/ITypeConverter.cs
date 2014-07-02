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

namespace NReco {

	/// <summary>
	/// Type converter interface.
	/// </summary>
	public interface ITypeConverter {
		
		/// <summary>
		/// Determines whether the type can be converted to the specified data type. 
		/// </summary>
		/// <param name="fromType">source type</param>
		/// <param name="toType">destination type</param>
		/// <returns>true if the source type can be converted to the destination type</returns>
		bool CanConvert(Type fromType, Type toType);
		
		/// <summary>
		/// Returns an object of the specified type and whose value is equivalent to the specified object.
		/// </summary>
		/// <param name="o">original object instance</param>
		/// <param name="toType">the type of object to return</param>
		/// <returns>An object whose type is toType and whose value is equivalent to original object</returns>
		object Convert(object o, Type toType);
	}
}
