#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2014 Vitaliy Fedorchenko
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
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Routing;
using NReco;
using NReco.Converting;
using NReco.Logging;
using NReco.Collections;

namespace NReco.Application.Web.Forms {
	
	/// <summary>
	/// Control class extensions.
	/// </summary>
	public static class ControlUtils {

		/// <summary>
		/// Returns control parents axis of specified type.
		/// </summary>
		/// <returns>control parents axis ordered from direct parent to control tree root</returns>
		public static IEnumerable<T> GetParents<T>(Control ctrl)  {
			while (ctrl.Parent != null) {
				ctrl = ctrl.Parent;
				if (ctrl is T)
					yield return (T)((object)ctrl);
			}
		}

		/// <summary>
		/// Returns control childres of specified type.
		/// </summary>
		/// <remarks>
		/// This method performs breadth-first search (that can avoid full subtree traversal for some cases)
		/// and doesn't uses much memory even for huge subtrees.
		/// </remarks>
		public static IEnumerable<T> GetChildren<T>(Control ctrl) {
			var q = new Queue<Control>();
			for (int i = 0; i < ctrl.Controls.Count; i++)
				q.Enqueue(ctrl.Controls[i]);
			while (q.Count>0) {
				var c = q.Dequeue();
				if (c is T)
					yield return (T)((object)c);
				for (int i = 0; i < c.Controls.Count; i++)
					q.Enqueue(c.Controls[i]);
			}
		}

		public static void SetSelectedItems(ListControl ctrl, string[] values) {
			SetSelectedItems(ctrl, values, false);
		}

		public static void SetSelectedItems(ListControl ctrl, string[] values, bool preserveOrder) {
			foreach (ListItem itm in ctrl.Items)
				itm.Selected = false;
			if (values!=null) {
				if (preserveOrder) {
					int i = 0;
					foreach (string val in values) {
						var itm = ctrl.Items.FindByValue(values[i]);
						if (itm!=null) {
							itm.Selected = true;
							ctrl.Items.Remove(itm);
							ctrl.Items.Insert(i++, itm);
						}
					}
				} else {
					foreach (ListItem itm in ctrl.Items)
						if (values.Contains(itm.Value))
							itm.Selected = true;
				}
			}
		}
		public static string[] GetSelectedItems(ListControl ctrl) {
			var q = from ListItem r in ctrl.Items
					where r.Selected
					select r.Value;
			var res = new List<string>();
			foreach (var val in q)
				res.Add(val);
			return res.ToArray();
		}


	}

}
