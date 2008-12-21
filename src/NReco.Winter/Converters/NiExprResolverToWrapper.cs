using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using NI.Common.Expressions;
using NI.Common.Providers;
using NReco.Converters;

namespace NReco.Winter.Converters {
	
	/// <summary>
	/// From NReco expression provider to NI IExpressionResolver interface wrapper
	/// </summary>
	public class NiExprResolverToWrapper : IExpressionResolver {
		IProvider<ExpressionContext<string>,object> _UnderlyingExprProvider;

		public IProvider<ExpressionContext<string>, object> UnderlyingExprProvider {
			get { return _UnderlyingExprProvider; }
			set { _UnderlyingExprProvider = value; }
		}

		public NiExprResolverToWrapper(IProvider<ExpressionContext<string>, object> prv) {
			_UnderlyingExprProvider = prv;
		}

		public object Evaluate(IDictionary context, string expression) {
			IDictionary<string, object> varContext = TypeManager.Convert(context, typeof(IDictionary<string, object>)) as IDictionary<string, object>;
			return UnderlyingExprProvider.Provide( 
				new ExpressionContext<string>(expression, varContext) );
		}

	}
}
