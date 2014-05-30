using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Data;

using NI.Data;
using NI.Data.Triggers;

namespace NReco.Dsm.Data {
	
	/// <summary>
	/// Special data trigger that implements data schema declarative rules
	/// </summary>
	public class DataSchemaTriggerHandler {
		
		public IDalc LogDalc { get; set; }

		public IDictionary<string,string> LogTables { get; set; }

		public SetColumn[] SetColumns { get; set; }

		public void OnDataRowHandler(DataRowTriggerEventArgs dataRowArg) {
			WriteLog(dataRowArg);
			ApplySetColumns(dataRowArg);
		}

		protected virtual void ApplySetColumns(DataRowTriggerEventArgs dataRowArg) {
			EnsureTableToSetColumns();
			if (TableToSetColumns!=null && TableToSetColumns.ContainsKey(dataRowArg.Row.Table.TableName)) {
				foreach (var set in TableToSetColumns[dataRowArg.Row.Table.TableName])
					if ( (set.Action & dataRowArg.Action)==dataRowArg.Action) {
						set.Apply(dataRowArg.Row);
					}
				
			}
		}

		IDictionary<string,IList<SetColumn>> TableToSetColumns = null;
		SetColumn[] TableToSetColumnsSource = null;

		protected void EnsureTableToSetColumns() {
			if (TableToSetColumnsSource != SetColumns ) {
				TableToSetColumns = new Dictionary<string,IList<SetColumn>>();
				foreach (var set in SetColumns) {
					if (!TableToSetColumns.ContainsKey(set.TableName))
						TableToSetColumns[set.TableName] = new List<SetColumn>();
					TableToSetColumns[set.TableName].Add(set);
				}
				TableToSetColumnsSource = SetColumns;
			}
		}

		protected virtual void WriteLog(DataRowTriggerEventArgs dataRowArg) {
			 if (LogTables.ContainsKey(dataRowArg.Row.Table.TableName) &&
				(dataRowArg.Action==DataRowActionType.Inserted
					|| dataRowArg.Action==DataRowActionType.Updated
					|| dataRowArg.Action==DataRowActionType.Deleted)) {
				object userName = DBNull.Value;
				if (Thread.CurrentPrincipal!=null && Thread.CurrentPrincipal.Identity!=null && Thread.CurrentPrincipal.Identity.Name!=null)
					userName = Thread.CurrentPrincipal.Identity.Name;
				
				var data = new Dictionary<string,IQueryValue>() {
					{"action", (QConst) dataRowArg.Action.ToString().ToLower() },
					{"timestamp", (QConst)DateTime.Now},
					{"username", (QConst)userName}
				};
				foreach (var pkCol in dataRowArg.Row.Table.PrimaryKey) {
					data["record_"+pkCol.ColumnName] = new QConst( dataRowArg.Row[ pkCol ] );
				}
				LogDalc.Insert( LogTables[dataRowArg.Row.Table.TableName], data);
			}
		}


		public abstract class SetColumn {
			public string ColumnName { get; set; }
			public string TableName { get; set; }
			public DataRowActionType Action { get; set; }

			public SetColumn() {
			}

			public abstract void Apply(DataRow row);
		}

		public class SetGuid : SetColumn {
			public override void Apply(DataRow row) {
				var newGuid = Guid.NewGuid();
				if (row.Table.Columns[ColumnName].DataType==typeof(string)) {
					row[ColumnName] = newGuid.ToString();
				} else {
					row[ColumnName] = newGuid;
				}
			}
		}
		public class SetDateTimeNow : SetColumn {
			public override void Apply(DataRow row) {
				row[ColumnName] = DateTime.Now;
			}
		}
		public class SetIdentityName : SetColumn {
			public override void Apply(DataRow row) {
				if (Thread.CurrentPrincipal!=null && Thread.CurrentPrincipal.Identity!=null && Thread.CurrentPrincipal.Identity.Name!=null) {
					row[ColumnName] = Thread.CurrentPrincipal.Identity.Name;
				} else {
					row[ColumnName] = DBNull.Value;
				}
			}
		}
		public class SetFunc : SetColumn {
			public Func<DataRow,object> ValueFunc { get; set; }

			public override void Apply(DataRow row) {
				row[ColumnName] = ValueFunc(row) ?? DBNull.Value;
			}
		}

		public class SetIfNull : SetColumn {
			public SetColumn Set { get; set; }

			public override void Apply(DataRow row) {
				if (row.IsNull(ColumnName))
					Set.Apply(row);
			}
		}


	}
}
