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
using System.Data;
using NReco.Converting;
using DbDataRow = System.Data.DataRow;

namespace NReco.OGNL.Helpers {
	
	public static class List {

		public static long GetLength(object o) {
			if (o is IList)
				return ((IList)o).Count;
			if (o is ICollection)
				return ((ICollection)o).Count;
			if (o is IEnumerable) {
				long cnt = 0;
				foreach (var entry in (IEnumerable)o) cnt++;
				return cnt;
			}
			throw new InvalidCastException(String.Format("{0} is not a list", o));
		}

		public static bool Contains(object o, object elem) {
			if (o is IList)
				return ((IList)o).Contains(elem);
			if (o is IEnumerable) {
				foreach (var entry in (IEnumerable)o)
					if ((entry != null && entry.Equals(elem)) || (entry == null && elem == null))
						return true;
				return false;
			}
			throw new InvalidCastException(String.Format("{0} is not a list", o));
		}
		
		public static string Join(string separator, object o) {
			var arr = new List<string>();
			if (o is IList) {
				foreach (var elem in ((IList)o))
					if (elem!=null)
						arr.Add( elem.ToString() );
			} else if (o is IEnumerable) {
				foreach (var elem in ((IEnumerable)o))
					if (elem != null)
						arr.Add(elem.ToString());			
			} else {
				arr.Add( Convert.ToString(o) );
			}
			return String.Join(separator, arr.ToArray() );
		}
		
	}
}
