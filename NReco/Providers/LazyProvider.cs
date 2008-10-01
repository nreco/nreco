using System;
using System.Collections;
using System.Text;

namespace NReco.Providers {
	
	/// <summary>
	/// Lazy object provider wrapper.
	/// </summary>
	public class LazyProvider<Context,Result> : IProvider<Context,Result> {
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

		public Result Get(Context context) {
			IProvider prv = InstanceProvider.Get(ProviderName);
			if (prv==null)
				throw new ArgumentException("invalid operation name");
			return (Result)prv.Get(context);
		}

		object IProvider.Get(object context) {
			return Get( (Context)context );
		}


	}
}
