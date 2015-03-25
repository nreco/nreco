using System;
using System.Collections.Generic;
using System.Collections.Concurrent;
using System.Linq;
using System.Data;
using System.IO;
using System.ComponentModel;
using NI.Data;
using NReco.Logging;

namespace NReco.Dsm.Data {

	public class ConstDataSetFactory : IDisposable {

		static ILog log = LogManager.GetLogger(typeof(ConstDataSetFactory));

		public string DataSetXml { get; private set; }

		public bool ReadOnly { get; private set; }

		public IDataSetFactory DataSetFactory { get; set; }

		public IDictionary<string,string> SchemaMapping { get; set; }

		public ConstDataSetFactory(string dataSetXml, bool readOnly) {
			DataSetXml = dataSetXml;
			ReadOnly = readOnly;
		}

		static Dictionary<string,ConstDataSetPoolEntry> globalPool = new Dictionary<string,ConstDataSetPoolEntry>();

		private List<ConstDataSet> localInstances = new List<ConstDataSet>();

		public static void ClearGlobalPool() {
			globalPool.Clear();
		}

		public int NewInstanceCounter {
			get { return newInstanceCount; }
		}

		int newInstanceCount = 0;

		public DataSet GetDataSet() {
			ConstDataSetPoolEntry poolEntry = null;
			if (!globalPool.TryGetValue(DataSetXml, out poolEntry)) {
				poolEntry = new ConstDataSetPoolEntry() {
					OriginalDataSet = LoadDataSetFromXml(),
					Pool = new ConcurrentBag<ConstDataSet>()
				};
				globalPool[DataSetXml] = poolEntry;
			}
			if (ReadOnly) {
				ConstDataSet constDs = null;
				if (!poolEntry.Pool.TryTake(out constDs)) {
					constDs = (ConstDataSet)poolEntry.OriginalDataSet.Copy();
					newInstanceCount++;
					constDs.MakeReadOnlyColumns();
					constDs.SubscribeOnChangeEvents();
				}
				localInstances.Add(constDs);
				return constDs;
			} else {
				// global pool is not used in this case
				var ds = poolEntry.OriginalDataSet.Copy();
				newInstanceCount++;
				return ds;
			}
		}

		public void Dispose() {
			if (localInstances.Count > 0) {
				ConstDataSetPoolEntry poolEntry = null;
				if (globalPool.TryGetValue(DataSetXml, out poolEntry)) {
					foreach (var ds in localInstances)
						if (!ds.IsDirty)
							poolEntry.Pool.Add(ds);
					localInstances.Clear();
				}
			}
		}

		internal ConstDataSet LoadDataSetFromXml() { 
			var ds = new ConstDataSet();
			ds.ReadXml(new StringReader(DataSetXml), XmlReadMode.Auto );
			if (DataSetFactory != null) {
				var dsWithSchema = new ConstDataSet();
				foreach (DataTable t in ds.Tables) {
					var schemaTblName = t.TableName;
					if (SchemaMapping.ContainsKey(schemaTblName))
						schemaTblName = SchemaMapping[schemaTblName];
					var tblDs = DataSetFactory.GetDataSet(schemaTblName);
					if (tblDs != null) { 
						var schemaTbl = tblDs.Tables[schemaTblName].Clone();
						schemaTbl.TableName = t.TableName;
						dsWithSchema.Tables.Add( schemaTbl );
					}
				}
				dsWithSchema.ReadXml(new StringReader(DataSetXml), XmlReadMode.Auto );
			}
			return ds;
		}

		internal class ConstDataSetPoolEntry {
			internal ConstDataSet OriginalDataSet;
			internal ConcurrentBag<ConstDataSet> Pool;
		}

		internal class ConstDataSet : DataSet {

			static ILog log = LogManager.GetLogger(typeof(ConstDataSet));

			internal bool IsDirty { get; private set; }

			public ConstDataSet() {
				IsDirty = false;
			}

			internal void MakeReadOnlyColumns() {
				foreach (DataTable t in Tables)
					foreach (DataColumn c in t.Columns)
						c.ReadOnly = true;
			}

			internal void SubscribeOnChangeEvents() {
				var collectionChanged = new CollectionChangeEventHandler(OnDataSetChanged);
				var rowChanged = new DataRowChangeEventHandler(OnDataSetChanged);
				Tables.CollectionChanged += collectionChanged;
				foreach (DataTable t in Tables) {
					t.Columns.CollectionChanged += collectionChanged;
					t.TableNewRow += new DataTableNewRowEventHandler(OnDataSetChanged);
					t.TableCleared += new DataTableClearEventHandler(OnDataSetChanged);
					t.Constraints.CollectionChanged += collectionChanged;
					t.RowDeleting += rowChanged;
					t.RowDeleted += rowChanged;
					t.RowChanging += rowChanged;
					t.RowChanged += rowChanged;
				}
			}

			void OnDataSetChanged(object sender, EventArgs e) {
				IsDirty = true;
				log.Write(LogEvent.Warn, "Readonly DataSet was modified and marked as dirty.");
			}

		}

	}

}
