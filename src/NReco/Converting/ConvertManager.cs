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
		static Dictionary<ConvertPair, ITypeConverter> KnownPairConverters = new Dictionary<ConvertPair, ITypeConverter>(1000);
		const int MaxKnownPairConverters = 10000;

		static ConvertManager() {
			_Converters = new List<ITypeConverter>();
			// default set
			Converters.Add(new CastConverter());
			Converters.Add(new GenericDictionaryConverter());
			Converters.Add(new GenericListConverter());
			Converters.Add(new GenericCollectionConverter());
			Converters.Add(new DataRowConverter());
			Converters.Add(new ArrayConverter());
			Converters.Add(new DefaultConverter());
			Converters.Add(new NullableConverter());
			Converters.Add(new DelegateConverter());
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
							addedNewConv++;
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
			var convPair = new ConvertPair(fromType,toType);
			ITypeConverter converter;
			if (KnownPairConverters.TryGetValue(convPair, out converter))
				return converter;

			for (int i=0; i<Converters.Count; i++) {
				var conv = Converters[i];
				if (conv!=null && conv.CanConvert(fromType, toType)) {

					// check also for cache overload
					if (KnownPairConverters.Count > MaxKnownPairConverters) {
						// clear is not thread safe. Lets just re-create cache dictionary instance
						KnownPairConverters = new Dictionary<ConvertPair, ITypeConverter>(1000);
					}

					// remember in cache
					// write lock should be enough
					// we'll not use read lock for performance reasons
					lock (KnownPairConverters) {
						KnownPairConverters[convPair] = conv;
					}

					return conv;
				}
			}
				
			return null;
		}

		public static bool CanChangeType(Type fromType, Type toType) {
			return FindConverter(fromType,toType)!=null;
		}

		public static object ChangeType(object o, Type toType) {
			try {
				if (o == null) {
					if (!toType.IsValueType)
						return null;
					else
						return Activator.CreateInstance(toType); // try "default"
				}

				ITypeConverter conv = FindConverter(o.GetType(), toType);
				if (conv != null)
					return conv.Convert(o, toType);

				return Convert.ChangeType(o, toType, System.Globalization.CultureInfo.InvariantCulture);
			} catch (Exception ex) {
				string msg = String.Format("Cannot convert {0} to {1}: {2}", (o != null ? (object)o.GetType() : (object)"null"), toType, ex.Message);
				log.Write(LogEvent.Warn, msg);
				throw new InvalidCastException(msg, ex);
			}
		}

		public static T ChangeType<T>(object o) {
			return (T)ChangeType(o, typeof(T));
		}

		internal struct ConvertPair {
			public Type FromType;
			public Type ToType;
			internal ConvertPair(Type from, Type to) {
				FromType = from;
				ToType = to;
			}
			public override int  GetHashCode() {
 				return FromType.GetHashCode()^ToType.GetHashCode();
			}
			public override bool Equals(object obj) {
 				if (obj is ConvertPair) {
					var cnvPair = (ConvertPair)obj;
					return FromType==cnvPair.FromType && ToType==cnvPair.ToType;
				}
				return base.Equals(obj);
			}

		}

	}
}
