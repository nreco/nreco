using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;
using NReco.Converting;

namespace NReco {
	
	/// <summary>
	/// Lazy delegate proxy implementation 
	/// </summary>
	public class LazyDelegateAdapter : DelegateAdapter {

		Func<Delegate> DelegateFactory;

		/// <summary>
		/// Initializes new instance of LazyDelegateAdapter with specified factory that provides delegate to invoke
		/// </summary>
		/// <param name="delegateFactory">delegate that provides lazy delegate</param>
		public LazyDelegateAdapter(Func<Delegate> delegateFactory) {
			DelegateFactory = delegateFactory;
		}

		protected override object Invoke(params object[] args) {
			var deleg = DelegateFactory();
			var delegParams = deleg.Method.GetParameters();
			if (delegParams.Length != args.Length)
				throw new TargetParameterCountException(
					String.Format("Target delegate expects {0} parameters", delegParams.Length));

			var resolvedArgs = new object[args.Length];
			for (int i = 0; i < resolvedArgs.Length; i++) {
				resolvedArgs[i] = ConvertManager.ChangeType(args[i], delegParams[i].ParameterType);
			}
			return deleg.DynamicInvoke(resolvedArgs);
		}
	}
}
