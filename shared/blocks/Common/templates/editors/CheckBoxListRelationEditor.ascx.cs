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
using NReco.Web;
using NReco.Web.Site;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

public partial class CheckBoxListRelationEditor : NReco.Web.ActionUserControl {

	public string EntityIdField { get; set; }
	public string DalcServiceName { get; set; }

	public string LookupServiceName { get; set; }
	public string RelationSourceName { get; set; }
	public string LFieldName { get; set; }
	public string RFieldName { get; set; }

	public object EntityId { get; set; }

	protected override void OnLoad(EventArgs e) {
	}

	public void ExecuteAfter_Insert(ActionContext e) {
		OnDataBinding(EventArgs.Empty);
		EntityId = ((ActionDataSource.InsertEventArgs)e.Args).Values[EntityIdField];
		Save();
	}
	public void ExecuteAfter_Update(ActionContext e) {
		OnDataBinding(EventArgs.Empty);
		var updateArgs = (ActionDataSource.UpdateEventArgs)e.Args;
		if (updateArgs.Keys.Contains(EntityIdField))
			EntityId = updateArgs.Keys[EntityIdField];
		else
			EntityId = updateArgs.Values[EntityIdField];
		Save();
	}

	protected void Save() {
		var dalc = WebManager.GetService<IDalc>(DalcServiceName);
		dalc.Delete(new Query(RelationSourceName, (QField)LFieldName == new QConst(EntityId)));
		foreach (var id in checkboxes.SelectedValues)
			dalc.Insert(new Hashtable { { LFieldName, EntityId }, { RFieldName, id } }, RelationSourceName);
	}

	public string[] GetSelectedIds() {
		// select visible ids
		var ids = (from r in WebManager.GetService<IDalc>(DalcServiceName).Linq<DalcRecord>(RelationSourceName)
				   where r[LFieldName] == EntityId
				   select r[RFieldName]).ToArray<DalcValue>();
		return Array.ConvertAll<DalcValue, string>(ids, x => x.Value.ToString());
	}

}
