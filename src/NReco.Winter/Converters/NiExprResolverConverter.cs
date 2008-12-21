using System;
using System.Collections.Generic;
using System.Text;

using NReco.Converters;
using NI.Common.Expressions;

namespace NReco.Winter.Converters {
	
	public class NiExprResolverConverter : 
		BaseTypeConverter<IExpressionResolver,IProvider<ExpressionContext<string>,object>,NiExprResolverFromWrapper,NiExprResolverToWrapper> {

		public NiExprResolverConverter() {
		}

	}
}
