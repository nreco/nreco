using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using NI.Common.Expressions;
using NI.Common.Providers;
using NReco.Converters;

namespace NReco.Winter.Converters {
	
	/// <summary>
	/// From NI IExpressionResolver to NReco expr resolver interface wrapper
	/// </summary>
	public class NiExprResolverFromWrapper : IProvider<ExpressionContext<string>,object> {
		IExpressionResolver _UnderlyingExprResolver;

		public IExpressionResolver UnderlyingExprResolver {
			get { return _UnderlyingExprResolver; }
			set { _UnderlyingExprResolver = value; }
		}

		public NiExprResolverFromWrapper(IExpressionResolver exprResolver) {
			_UnderlyingExprResolver = exprResolver;
		}

		public object Provide(ExpressionContext<string> context) {
			IDictionary contextDict = TypeManager.Convert(context.Variables, typeof(IDictionary) ) as IDictionary;
			return UnderlyingExprResolver.Evaluate(contextDict, context.Expression);
		}
	}
}
