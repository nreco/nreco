using System;
using System.Collections.Generic;
using System.Reflection;
using System.Linq;
using System.Text;

namespace NReco {
	
	public class PartialDelegateAdapter : DelegateAdapter {

		static object _KeepArg = new object();

		/// <summary>
		/// Value that used as marker to keep argument in resulting delegate
		/// </summary>
		public static object KeepArg {
			get { return _KeepArg; }
		}

		public object[] FixedArgs { get; private set; }

		public Delegate Target { get; private set; }

		public PartialDelegateAdapter(Delegate target, object[] fixedArgs) {
			FixedArgs = fixedArgs;
			Target = target;
		}

		protected override object Invoke(params object[] args) {
			var targetParams = Target.Method.GetParameters();
			var allArgs = new object[targetParams.Length];

			int argIdx = 0;
			for (int i = 0; i < allArgs.Length; i++) {
				var hasFixedParam = FixedArgs.Length > i && !KeepArg.Equals(FixedArgs[i]);
				if (hasFixedParam) {
					allArgs[i] = FixedArgs[i];
				} else {
					if (args.Length > argIdx) {
						allArgs[i] = args[argIdx++];
					} else {
						throw new TargetParameterCountException("Insufficient number of arguments");
					}
				}
			}

			return Target.DynamicInvoke(allArgs);
		}

	}

}
