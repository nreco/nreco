#region License
/*
 * NReco library (http://code.google.com/p/nreco/)
 * Copyright 2008 Vitaliy Fedorchenko
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
using System.Collections;
using System.Text;

using NReco;
using NReco.Collections;
using ognl;

namespace NReco.OGNL {
	
	public class OgnlExprProvider : IProvider<ExpressionContext<string>,object> {
		static ClassResolver DefaultClassResolverInstance = new DefaultClassResolver();

		ClassResolver _ClassResolver = DefaultClassResolverInstance;

		public ClassResolver TypeResolver {
			get { return _ClassResolver; }
			set { _ClassResolver = value; }
		}


		protected object Eval(string code, IDictionary<string,object> context) {
			object root = context;
			IDictionary dictContext = new DictionaryWrapper<string, object>(context);
			IDictionary variables = Ognl.addDefaultContext(root, TypeResolver, dictContext);
			try {
				return Ognl.getValue(code, variables, root);
			} catch (Exception ex) {
				throw new Exception("OGNL code evaluation failed (" + code + "): " + ex.Message, ex);
			}
		}

		public object Provide(ExpressionContext<string> context) {
			return Eval(context.Expression, context.Variables);
		}

	}
}
