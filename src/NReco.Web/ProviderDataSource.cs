using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel;
using System.Data;

using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace NReco.Web {

	/// <summary>
	/// Data source implementation based on provider service component
	/// </summary>
	public class ProviderDataSource : DataSourceControl {
		
		public string ProviderName { get; set; }

		public event EventHandler<ProviderDataSourceSelectEventArgs> Selecting;
		
		protected override DataSourceView GetView(string viewName) {
			return new ProviderDataSourceView(this, viewName);
		}

		protected override ICollection GetViewNames() {
			return new string[] { String.Empty };
		}

		internal void OnSelecting(object sender, ProviderDataSourceSelectEventArgs e) {
			if (Selecting != null)
				Selecting(sender, e);
		}		

		public class ProviderDataSourceView : DataSourceView {
			ProviderDataSource DS;

			public ProviderDataSourceView(ProviderDataSource source, string viewName)
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
				var selectArgs = new ProviderDataSourceSelectEventArgs(arguments);
				DS.OnSelecting(this, selectArgs);
				var provider = WebManager.GetService<IProvider<object,object>>(DS.ProviderName);
				if (provider==null)
					throw new Exception("Underlying data provider service not found: "+DS.ProviderName);
				var result = provider.Provide(selectArgs.ProviderContext);
				callback(result is IList ? (IEnumerable)result : new object[] { result } );
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


	public class ProviderDataSourceSelectEventArgs : EventArgs {

		public object ProviderContext { get; set; }

		public DataSourceSelectArguments SelectArgs { get; set; }

		public ProviderDataSourceSelectEventArgs(DataSourceSelectArguments args) {
			SelectArgs = args;
		}
	}	
	
}
