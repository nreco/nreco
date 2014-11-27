using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using NReco;
using NI.Ioc;

namespace NReco.Application.Ioc {
	
	/// <summary>
	/// Creates lazy delegate adapter that uses IComponentFactory for resolving real delegate instance.
	/// </summary>
	public class LazyDelegateFactory : IFactoryComponent, IComponentFactoryAware {
		
		public IComponentFactory ComponentFactory { private get; set; }

		private Type DelegateType { get; set; }

		private string DelegateComponentName { get; set; }

		public LazyDelegateFactory(string delegateComponentName, Type delegateType) {
			DelegateType = delegateType;
			DelegateComponentName = delegateComponentName;
		}

		protected Delegate GetRealDelegate() {
			return (Delegate)ComponentFactory.GetComponent(DelegateComponentName, DelegateType);
		}

		public object GetObject() {
			var lazyDelegAdapter = new LazyDelegateAdapter(GetRealDelegate);
			return lazyDelegAdapter.GetDelegate(DelegateType);
		}

		public Type GetObjectType() {
			return DelegateType;
		}


	}

}
