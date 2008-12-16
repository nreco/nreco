using System;
using System.Collections.Generic;
using System.Text;
using System.Web.Compilation;
using System.CodeDom;

namespace NReco.Web {
	
	/// <summary>
	/// Service expression builder used for ASP.NET property expressions.
	/// </summary>
	/// <remarks>
	/// With this expression builder control properties could be initalized with service instance:
	/// <code><CTRL:MyCtrl runat="server" MyPrv='<%$ service: myProvider %>'/></code>
	/// Note that if myProvider is incompatible with MyPrv property it will be converted to desired type using type converters mechanizm.
	/// </remarks>
	public class ServiceExpressionBuilder : ExpressionBuilder {

		public override CodeExpression GetCodeExpression(System.Web.UI.BoundPropertyEntry entry, object parsedData, ExpressionBuilderContext context) {
			return new CodeMethodInvokeExpression(
				new CodeTypeReferenceExpression(typeof(WebManager) ),
				"GetService",
				new CodePrimitiveExpression( entry.Expression.Trim() ),
				new CodeTypeOfExpression( new CodeTypeReference(entry.PropertyInfo.PropertyType ) ) );
		}
	}

}
