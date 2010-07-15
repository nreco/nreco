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

using NReco.Converting;

public static class AssertHelper
{
	public static bool IsFuzzyTrue(object o) {
		if (o is bool)
			return (bool)o;
		if (o==null || o==DBNull.Value)
			return false;
		if (o is string && (string)o == String.Empty)
			return false;
		if (o is ICollection)
			return ((ICollection)o).Count > 0;
		if (o is int)
			return (int)o!=0;
		if (o is decimal)
			return (decimal)o!=0;
		if (o is long)
			return (long)o!=0;
		if (o is byte)
			return (byte)o!=0;
		if (o is DateTime)
			return ((DateTime)o)!=DateTime.MinValue;
		return ConvertManager.ChangeType<bool>(o);
	}
	
	public static bool IsFuzzyEmpty(object o) {
		if (o==null || o==DBNull.Value)
			return true;
		if (o is string && (string)o == String.Empty)
			return true;
		return false;
	}
	
	public static bool IsFuzzyEmptyOrWhitespace(object o) {
		if (IsFuzzyEmpty(o))
			return true;
		if (o is string && ((string)o).Trim() == String.Empty)
			return true;
		return false;
	}	
	
	public static bool AreEquals(object o1, object o2) {
		if (o1==null && o2==null)
			return true;
		if (o1!=null) {
			return o1.Equals(o2);
		}
		if (o2!=null) {
			return o2.Equals(o1);
		}
		return false;
	}
}