using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NReco.Converting;

namespace NReco.Statements {
	
	public class StatementDelegate {

		public IStatement Statement { get; private set; }

		public string[] ArgumentKeys { get; private set; }

		public string ResultKey { get; private set; }

		public StatementDelegate(IStatement statement, string[] argKeys, string resultKey) {
			Statement = statement;
			ArgumentKeys = argKeys;
			ResultKey = resultKey;
		}

		private void SetArguments(IDictionary<string,object> context, object[] args) {
			for (int i = 0; i < ArgumentKeys.Length && i < args.Length; i++) {
				context[ArgumentKeys[i]] = args[i];
			}
		}

		protected object Invoke(params object[] args) {
			var context = new Dictionary<string, object>();
			SetArguments(context, args);
			Statement.Execute(context);
			return context.ContainsKey(ResultKey) ? context[ResultKey] : null;
		}

		public TResult InvokeFunc<TResult>() {
			return ConvertManager.ChangeType<TResult>(Invoke());
		}

		public TResult InvokeFunc<T1,TResult>(T1 arg1) {
			return ConvertManager.ChangeType<TResult>(Invoke( arg1 ));
		}

		public TResult InvokeFunc<T1, T2, TResult>(T1 arg1, T2 arg2) {
			return ConvertManager.ChangeType<TResult>(Invoke(arg1, arg2));
		}

		public TResult InvokeFunc<T1, T2, T3, TResult>(T1 arg1, T2 arg2, T3 arg3) {
			return ConvertManager.ChangeType<TResult>(Invoke(arg1, arg2, arg3));
		}

		public TResult InvokeFunc<T1, T2, T3, T4, TResult>(T1 arg1, T2 arg2, T3 arg3, T4 arg4) {
			return ConvertManager.ChangeType<TResult>(Invoke(arg1, arg2, arg3, arg4));
		}

		public TResult InvokeFunc<T1, T2, T3, T4, T5, TResult>(T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5) {
			return ConvertManager.ChangeType<TResult>(Invoke(arg1, arg2, arg3, arg4, arg5));
		}

	}

}
