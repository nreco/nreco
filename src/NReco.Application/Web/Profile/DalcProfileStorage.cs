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
using System.Collections.Generic;
using System.Collections;
using System.Reflection;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Web.Profile;
using System.Data;
using NI.Data;

using NReco;
using NReco.Logging;
using NReco.Converting;

namespace NReco.Application.Web.Profile {
	
	public class DalcProfileStorage : IProfileStorage {
		static ILog log = LogManager.GetLogger(typeof(DalcProfileStorage));

		public DataRowDalcMapper DataManager { get; set; }
		public ProfileSource[] Sources { get; set; }

		public DalcProfileStorage() {
		}

		protected string ResolveFieldName(string propName, ProfileSource src) {
			return src.FieldsMapping.ContainsKey(propName) ? src.FieldsMapping[propName] : propName;
		}

		public bool Delete(string userName) {
			bool oneDeleted = false;
			foreach (var source in Sources) {
				var row = DataManager.Load(new Query(source.TableName, (QField)ResolveFieldName("Username", source) == (QConst)userName));
				if (row != null) {
					oneDeleted = true;
					DataManager.Delete(row);
				}
			}
			return oneDeleted;
		}

		public SettingsPropertyValueCollection LoadValues(string userName, SettingsPropertyCollection props) {
			var svc = new SettingsPropertyValueCollection();
			// holds sourcename->data pairs
			var loadedData = new Dictionary<string, IDictionary>();
			foreach (SettingsProperty prop in props) {
				EnsureDataLoaded(userName, prop.Name, loadedData);
				var pv = new SettingsPropertyValue(prop);

				object value = null; 
				// lets try to locate property value
				foreach (var src in Sources)
					if (src.FieldsMapping.ContainsKey(prop.Name)) {
						value = loadedData[src.TableName][ ResolveFieldName(prop.Name,src) ];
						break;
					}
				if (value == null || value == DBNull.Value) {
					// leave default value
				} else {
					pv.PropertyValue = value;
					pv.IsDirty = false;
				}

				svc.Add(pv);
			}
			return svc;
		}

		protected void EnsureDataLoaded(string userName, string pName, Dictionary<string,IDictionary> loadedData) {
			foreach (var src in Sources)
				if (src.FieldsMapping.ContainsKey(pName) && !loadedData.ContainsKey(src.TableName)) {
					var data = DataManager.Dalc.LoadRecord( new Query(src.TableName, (QField)ResolveFieldName("Username", src) == (QConst)userName));
					loadedData[src.TableName] = data;
				}
		}

		protected void EnsureDataLoaded(string userName, string pName, Dictionary<string, DataRow> loadedData) {
			foreach (var src in Sources)
				if (src.FieldsMapping.ContainsKey(pName) && !loadedData.ContainsKey(src.TableName)) {
					var row = DataManager.Load( new Query(src.TableName, (QField)ResolveFieldName("Username", src) == (QConst)userName));
					if (row == null) {
						row = DataManager.Create(src.TableName);
						row[ResolveFieldName("Username", src)] = userName;
					}
					loadedData[src.TableName] = row;
				}
		}


		public void SaveValues(string userName, SettingsPropertyValueCollection values) {
			// holds sourcename->datarow pairs
			var profileRows = new Dictionary<string, DataRow>();
			foreach (SettingsPropertyValue value in values) 
				if (value.IsDirty) {
					EnsureDataLoaded(userName, value.Property.Name, profileRows);

					foreach (var src in Sources)
						if (src.FieldsMapping.ContainsKey(value.Property.Name)) {
							var dataCol = src.FieldsMapping[value.Property.Name];
								profileRows[src.TableName][dataCol] = ResolveFieldValue(profileRows[src.TableName].Table.Columns[dataCol], value);
						}
				}
			foreach (var entry in profileRows) {
				log.Write(LogEvent.Debug, "Saving profile values for username={0}", userName);
				DataManager.Update(entry.Value);
			}
		}

		protected object ResolveFieldValue(DataColumn col, SettingsPropertyValue value) {
			// note: this routine ignores serialization option - anyway it doesn't work in medium trust
			if (value.PropertyValue == null || 
				value.PropertyValue==DBNull.Value ||
				(col.DataType != typeof(string) && (value.PropertyValue is string) && String.IsNullOrEmpty(value.PropertyValue as string)))
				return DBNull.Value;
			// if DB type and property type are matched - just return raw value
			if (value.Property.PropertyType == col.DataType)
				return value.PropertyValue;
			return ConvertManager.ChangeType(value.PropertyValue,col.DataType);
		}

		/// <summary>
		/// Describes one profile values DALC data source
		/// </summary>
		public class ProfileSource {
			public string TableName { get; set; }
			public IDictionary<string, string> FieldsMapping { get; set; }
		}




	}
}
