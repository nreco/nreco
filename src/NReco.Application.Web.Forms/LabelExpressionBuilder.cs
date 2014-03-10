#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2014 Vitaliy Fedorchenko
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
	/// Label expression builder used for ASP.NET property expressions.
	/// </summary>
	/// <remarks>
	/// With this expression builder control properties could be initalized with processed label:
	/// <code><asp:Label runat="server" Text='<%$ label: Hello %>'/></code>
	/// </remarks>
	public class LabelExpressionBuilder : ExpressionBuilder {

		public override CodeExpression GetCodeExpression(System.Web.UI.BoundPropertyEntry entry, object parsedData, ExpressionBuilderContext context) {
			return new CodeMethodInvokeExpression(
				new CodeTypeReferenceExpression(typeof(LabelExpressionBuilder)),
				"GetLabel",
				new CodePrimitiveExpression(entry.Expression.Trim()),
				new CodePrimitiveExpression(context.VirtualPath));
		}

		public static string GetLabel(string label, string context) {
			return AppContext.GetLabel(label, context);
		}
	}

}
