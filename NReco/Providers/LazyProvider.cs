using System;
using System.Collections;
using System.Text;

namespace NReco.Providers {
	
	/// <summary>
	/// Lazy provider proxy.
	/// </summary>
	public class LazyProvider : IProvider {
		IProvider<string,IProvider> _InstanceProvider;
		string _ProviderName;

		public string ProviderName {
			get { return _ProviderName; }
			set { _ProviderName = value; }
		}

		public IProvider<string, IProvider> InstanceProvider {
			get { return _InstanceProvider; }
			set { _InstanceProvider = value; }
		}

		public object Provide(object context) {
			IProvider prv = InstanceProvider.Provide(ProviderName);
			if (prv==null)
				throw new ArgumentException("invalid operation name");
			return prv.Provide(context);
		}

	}


}
