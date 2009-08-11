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
using System.Text;
using System.Configuration;
using System.ComponentModel;
using NReco.Logging;

namespace NReco.Converting {
	
	/// <summary>
	/// Provides access to default type conversion mechanizm.
	/// </summary>
	public static class ConvertManager {
		static IList<ITypeConverter> _Converters;
		static ILog log = LogManager.GetLogger(typeof(ConvertManager));

		static ConvertManager() {
			_Converters = new List<ITypeConverter>();
			// default set
			Converters.Add(new GenericDictionaryConverter());
			Converters.Add(new GenericListConverter());
			Converters.Add(new ProviderConverter());
			Converters.Add(new OperationConverter());
			Converters.Add(new GenericCollectionConverter());
			Converters.Add(new ContextConverter());
			Converters.Add(new DataRowConverter());
			Converters.Add(new ArrayConverter());
		}

		/// <summary>
		/// Configure type manager from application config.
		/// </summary>
		public static void Configure() {
			string sectionName = typeof(ConvertManager).Namespace;
			object config = ConfigurationSettings.GetConfig(sectionName);
			if (config == null)
				config = ConfigurationSettings.GetConfig(sectionName.ToLower());
			if (config != null) {
				IList<Type> convTypes = config as IList<Type>;
				if (convTypes == null) {
					log.Write(LogEvent.Warn, "Invalid converters configuration type: {0}", config.GetType());
				} else {
					int addedNewConv = 0;
					foreach (Type t in convTypes) {
						ITypeConverter conv = Activator.CreateInstance(t) as ITypeConverter;
						if (conv != null) {
							// skip duplicates
							Converters.Add(conv);
						} else {
							log.Write(LogEvent.Warn, "Converter type {0} does not implement ITypeConverter interface - ignored", t);
						}
					}
					log.Write(LogEvent.Info, "Initialized {0} new converters from application config.", addedNewConv);
				}
					
			}
		}

		/// <summary>
		/// List of default converters.
		/// </summary>
		public static IList<ITypeConverter> Converters {
			get { return _Converters; }
		}
		
		/// <summary>
		/// Find converter in default converters for given conversion.
		/// </summary>
		/// <param name="fromType">from type</param>
		/// <param name="toType">to type</param>
		/// <returns>type converter that can perform conversion or null</returns>
		public static ITypeConverter FindConverter(Type fromType, Type toType) {
			for (int i=0; i<Converters.Count; i++)
				if (Converters[i].CanConvert(fromType, toType))
					return Converters[i];
			return null;
		}

		public static bool CanChangeType(Type fromType, Type toType) {
			return FindConverter(fromType,toType)!=null;
		}

		public static object ChangeType(object o, Type toType) {
			try {
				if (o == null) {
					if (!toType.IsValueType) return null;
					throw new InvalidCastException("Cannot convert null to value type");
				}
				// may be conversion is not needed
				if (toType == typeof(object))
					return o; // avoid TypeConvertor 'NotSupportedException'
				if (o != null && toType.IsInstanceOfType(o))
					return o;

				ITypeConverter conv = FindConverter(o.GetType(), toType);
				if (conv != null)
					return conv.Convert(o, toType);
				// maybe just simple types conversion
				var typeDescriptorConv = TypeDescriptor.GetConverter(o);
				if (typeDescriptorConv != null && typeDescriptorConv.CanConvertTo(toType))
					return typeDescriptorConv.ConvertTo(o, toType);

				return Convert.ChangeType(o, toType);
			} catch (Exception ex) {
				string msg = String.Format("Cannot convert {0} to {1}: {2}", (o != null ? (object)o.GetType() : (object)"null"), toType, ex.Message);
				log.Write(LogEvent.Error, msg);
				throw new InvalidCastException(msg, ex);
			}
		}

		public static T ChangeType<T>(object o) {
			return (T)ChangeType(o, typeof(T));
		}

	}
}
