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

		public override bool CanConvert(Type fromType, Type toType) {
			var res = base.CanConvert(fromType, toType);
			if (res) return true;
			// one way IProvider<object,object> -> IExpressionResolver wrapping is possible
			if (toType == typeof(IExpressionResolver) &&
				TypeHelper.FindGenericInterface(fromType, typeof(IProvider<,>)) != null)
				return true;
			return false;
		}

		public override object Convert(object o, Type toType) {
			// check for special case
			if (o!=null && toType == typeof(IExpressionResolver) &&
				TypeHelper.FindGenericInterface(o.GetType(), typeof(IProvider<,>)) != null) {
				var exprPrv = ConvertManager.ChangeType<IProvider<ExpressionContext<string>, object>>(o);
				return base.Convert(exprPrv, toType);
			}
			return base.Convert(o, toType);
		}
	}
}
