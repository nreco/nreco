using System;
using System.Collections.Generic;
using System.Text;
using System.Web.Compilation;
using System.CodeDom;

namespace NReco.Web {
	
	public class ServiceExpressionBuilder : ExpressionBuilder {

		public override CodeExpression GetCodeExpression(System.Web.UI.BoundPropertyEntry entry, object parsedData, ExpressionBuilderContext context) {
			return new CodeMethodInvokeExpression(
				new CodeTypeReferenceExpression(typeof(WebManager) ),
				"GetService",
				new CodePrimitiveExpression( entry.Expression.Trim() ),
				new CodeTypeOfExpression( new CodeTypeReference(entry.PropertyInfo.PropertyType ) ) );

			/*return new CodeSnippetExpression(
				String.Format("NReco.Web.WebManager.GetService<{1}>(\"{0}\")", 
					entry.Expression,
					entry.PropertyInfo.PropertyType.FullName));*/
		}
	}

}
