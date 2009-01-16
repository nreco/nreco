using System;
using System.Collections.Generic;
using System.Text;

using NReco.Converting;
using NI.Common.Expressions;

namespace NReco.Winter.Converting {
	
	public class NiExprResolverConverter : 
		BaseTypeConverter<IExpressionResolver,IProvider<ExpressionContext<string>,object>,NiExprResolverFromWrapper,NiExprResolverToWrapper> {

		public NiExprResolverConverter() {
		}

	}
}
