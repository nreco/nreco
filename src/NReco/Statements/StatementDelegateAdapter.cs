using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NReco.Converting;

namespace NReco.Statements {
	
	public class StatementDelegateAdapter : NReco.DelegateAdapter {

		public IStatement Statement { get; private set; }

		public string[] ArgumentKeys { get; private set; }

		public string ResultKey { get; private set; }

		public StatementDelegateAdapter(IStatement statement, string[] argKeys, string resultKey) {
			Statement = statement;
			ArgumentKeys = argKeys;
			ResultKey = resultKey;
		}

		private void SetArguments(IDictionary<string,object> context, object[] args) {
			for (int i = 0; i < ArgumentKeys.Length && i < args.Length; i++) {
				context[ArgumentKeys[i]] = args[i];
			}
		}

		protected override object Invoke(params object[] args) {
			var context = new Dictionary<string, object>();
			SetArguments(context, args);
			Statement.Execute(context);
			return context.ContainsKey(ResultKey) ? context[ResultKey] : null;
		}

	}

}
