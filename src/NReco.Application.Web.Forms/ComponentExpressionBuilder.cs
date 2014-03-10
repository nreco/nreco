#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008,2009 Vitaliy Fedorchenko
 * Distributed under the LGPL licence
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#endregion

using System;
using System.Collections.Generic;
using System.Text;
using System.Web.Compilation;
using System.CodeDom;

namespace NReco.Application.Web.Forms {
	
	/// <summary>
	/// Component injection expression builder used for ASP.NET property expressions.
	/// </summary>
	/// <remarks>
	/// With this expression builder control properties could be initalized with service instance:
	/// <code><CTRL:MyCtrl runat="server" MyProp='<%$ component: myProvider %>'/></code>
	/// Note that if myProvider is incompatible with MyPrv property it will be converted to desired type using type converters mechanizm.
	/// </remarks>
	public class ComponentExpressionBuilder : ExpressionBuilder {

		public override CodeExpression GetCodeExpression(System.Web.UI.BoundPropertyEntry entry, object parsedData, ExpressionBuilderContext context) {
			return new CodeMethodInvokeExpression(
				new CodeTypeReferenceExpression(typeof(ComponentExpressionBuilder)),
				"GetComponent",
				new CodePrimitiveExpression( entry.Expression.Trim() ),
				new CodeTypeOfExpression( new CodeTypeReference(entry.PropertyInfo.PropertyType ) ) );
		}

		public static object GetComponent(string name, Type t) {
			return AppContext.ComponentFactory.GetComponent(name, t);
		}
	}

}
