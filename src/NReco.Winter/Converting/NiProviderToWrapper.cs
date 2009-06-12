using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using NI.Common.Providers;
using NReco.Converting;

namespace NReco.Winter.Converting {
	
	/// <summary>
	/// From NReco IProvider to NI IObjectProvider interface wrapper
	/// </summary>
	public class NiProviderToWrapper<C,T> : IObjectProvider, IObjectListProvider, IStringListProvider {

		public IProvider<C, T> UnderlyingProvider { get; set; }

		public NiProviderToWrapper(IProvider<C,T> prv) {
			UnderlyingProvider = prv;
		}

		public object GetObject(object context) {
			C c;
			if (!(context is C) && context != null) {
				c = ConvertManager.ChangeType<C>(context);
			}
			else {
				c = (C)((object)context);
			}

			return UnderlyingProvider.Provide(c);
		}

		protected LT[] GetList<LT>(object context) {
			var res = GetObject(context);
			if (res is IEnumerable && !(res is string)) {
				var resList = new List<LT>();
				foreach (object o in ((IEnumerable)res))
					resList.Add( ConvertManager.ChangeType<LT>( o ) );
				return resList.ToArray();
			}
			return new[] { ConvertManager.ChangeType<LT>( res ) };
		}

		public IList GetObjectList(object context) {
			return GetList<object>(context);
		}

		public string[] GetStringList(object context) {
			return GetList<string>(context);
		}

	}
}
