using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel;
using System.Data;

using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using NReco.Collections;

using NReco.Application.Web;

namespace NReco.Dsm.WebForms {

	/// <summary>
	/// Data source implementation based on component that implements IEnumerable
	/// </summary>
	public class ComponentDataSource : DataSourceControl {
		
		public string ComponentName { get; set; }

		public event EventHandler<ComponentDataSourceSelectEventArgs> Selecting;
		
		protected override DataSourceView GetView(string viewName) {
			return new ComponentDataSourceView(this, viewName);
		}

		protected override ICollection GetViewNames() {
			return new string[] { String.Empty };
		}

		internal void OnSelecting(object sender, ComponentDataSourceSelectEventArgs e) {
			if (Selecting != null)
				Selecting(sender, e);
		}		

		public class ComponentDataSourceView : DataSourceView {
			ComponentDataSource DS;

			public ComponentDataSourceView(ComponentDataSource source, string viewName)
				: base(source, viewName) {
				DS = source;
			}

			protected override IEnumerable ExecuteSelect(DataSourceSelectArguments arguments) {
				IEnumerable callbackResult = null;
				DataSourceViewSelectCallback syncCallback = delegate(IEnumerable result) {
					callbackResult = result;
				};
				Select(arguments, syncCallback);
				return callbackResult;
			}

			public override void Select(DataSourceSelectArguments arguments, DataSourceViewSelectCallback callback) {
				var selectArgs = new ComponentDataSourceSelectEventArgs(arguments);
				DS.OnSelecting(this, selectArgs);
				var data = AppContext.ComponentFactory.GetComponent(DS.ComponentName, typeof(IEnumerable) ) as IEnumerable;
				if (data==null)
					throw new Exception("Component not found: " + DS.ComponentName);
				
				var result = new List<object>();
				foreach (var entry in data) {
					result.Add( entry is IDictionary ? new DictionaryView((IDictionary)entry) : entry );
				}
				callback(result);
			}

			public override void Delete(IDictionary keys, IDictionary oldValues, DataSourceViewOperationCallback callback) {
				throw new NotSupportedException();
			}

			public override void Insert(IDictionary values, DataSourceViewOperationCallback callback) {
				throw new NotSupportedException();
			}

			public override void Update(IDictionary keys, IDictionary values, IDictionary oldValues, DataSourceViewOperationCallback callback) {
				throw new NotSupportedException();
			}

			public override bool CanDelete {
				get { return false; }
			}

			public override bool CanUpdate {
				get { return false; }
			}

			public override bool CanInsert {
				get { return false; }
			}

			public override bool CanPage {
				get { return false; }
			}

			public override bool CanSort {
				get { return false; }
			}

			public override bool CanRetrieveTotalRowCount {
				get {
					return false;
				}
			}


		}

	}


	public class ComponentDataSourceSelectEventArgs : EventArgs {

		public DataSourceSelectArguments SelectArgs { get; set; }

		public ComponentDataSourceSelectEventArgs(DataSourceSelectArguments args) {
			SelectArgs = args;
		}
	}	
	
}
