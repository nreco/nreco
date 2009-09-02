using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;

using NReco;
using NReco.Collections;
using NReco.Converting;
using NReco.Web;
using NReco.Web.Site;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

public abstract class CommonRelationEditor : ActionUserControl {

	public string EntityIdField { get; set; }
	public string DalcServiceName { get; set; }

	public string LookupServiceName { get; set; }
	public string TextFieldName { get; set; }
	public string ValueFieldName { get; set; }

	public string RelationSourceName { get; set; }
	public string LFieldName { get; set; }
	public string RFieldName { get; set; }
	public string PositionFieldName { get; set; }

	public object EntityId {
		get { return ViewState["EntityId"]; }
		set { ViewState["EntityId"] = value; }
	}

	protected override void OnLoad(EventArgs e) {
	}

	public void ExecuteAfter_Select(ActionContext e) {
		if (!(e.Args is ActionDataSource.SelectEventArgs)) return;
		var data = ((ActionDataSource.SelectEventArgs)e.Args).Data;
		if (data != null)
			foreach (object o in data) {
				var record = ConvertManager.ChangeType<IDictionary<string, object>>(o);
				EntityId = record[EntityIdField];
			}
	}

	public void ExecuteAfter_Insert(ActionContext e) {
		if (!(e.Args is ActionDataSource.InsertEventArgs)) return;
		EntityId = ((ActionDataSource.InsertEventArgs)e.Args).Values[EntityIdField];
		Save();
	}
	public void ExecuteAfter_Update(ActionContext e) {
		var updateArgs = (ActionDataSource.UpdateEventArgs)e.Args;
		if (updateArgs.Keys.Contains(EntityIdField))
			EntityId = updateArgs.Keys[EntityIdField];
		else
			EntityId = updateArgs.Values[EntityIdField];
		Save();
	}
	public IEnumerable GetDataSource() {
		return DataSourceHelper.GetProviderDataSource(LookupServiceName,null);
	}

	abstract protected IEnumerable GetControlSelectedIds();

	protected void Save() {
		var dalc = WebManager.GetService<IDalc>(DalcServiceName);
		dalc.Delete(new Query(RelationSourceName, (QField)LFieldName == new QConst(EntityId)));
		int idx = 0;
		foreach (var id in GetControlSelectedIds() ) {
			var data = new Hashtable { { LFieldName, EntityId }, { RFieldName, id } };
			if (!String.IsNullOrEmpty(PositionFieldName))
				data[PositionFieldName] = idx++;
			dalc.Insert(data, RelationSourceName);
		}
	}

	public string[] GetSelectedIds() {
		// select visible ids
		var ids = String.IsNullOrEmpty(PositionFieldName) ?
			(from r in WebManager.GetService<IDalc>(DalcServiceName).Linq<DalcRecord>(RelationSourceName)
				   where r[LFieldName] == EntityId
				   select r[RFieldName]
				   ).ToArray<DalcValue>()			
				   :
			(from r in WebManager.GetService<IDalc>(DalcServiceName).Linq<DalcRecord>(RelationSourceName)
				   where r[LFieldName] == EntityId
				   orderby r[PositionFieldName]
				   select r[RFieldName]
				   ).ToArray<DalcValue>();
		return Array.ConvertAll<DalcValue, string>(ids, x => x.Value.ToString());
	}

}
