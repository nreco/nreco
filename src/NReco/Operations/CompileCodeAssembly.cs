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
using System.Text;
using System.CodeDom.Compiler;
using System.Reflection;
using System.Text;

namespace NReco.Operations {
	
	public class CompileCodeAssembly : IProvider<string,Assembly> {
		
		CodeDomProvider _DomProvider;
		string[] _RefAssemlies = null;

		public string[] RefAssemblies {
			get { return _RefAssemlies; }
			set { _RefAssemlies = value; }
		}

		public CodeDomProvider DomProvider {
			get { return _DomProvider; }
			set { _DomProvider = value; }
		}

		public CompileCodeAssembly() {
		}

		public CompileCodeAssembly(CodeDomProvider codeDomPrv) {
			DomProvider = codeDomPrv;
		}

		public CompileCodeAssembly(CodeDomProvider codeDomPrv, string[] refAssemblies) {
			DomProvider = codeDomPrv;
			RefAssemblies = refAssemblies;
		}


		public object Provide(object context) {
			return Provide( (string)context );
		}

		public Assembly Provide(string code) {
			ICodeCompiler icc = DomProvider.CreateCompiler();
			CompilerParameters cp = new CompilerParameters();
			if (RefAssemblies!=null) 
				for (int i = 0; i < RefAssemblies.Length; i++)
					cp.ReferencedAssemblies.Add(RefAssemblies[i]);
			cp.CompilerOptions = "/t:library";
			cp.GenerateInMemory = true;
			StringBuilder sb = new StringBuilder();

			CompilerResults cr = icc.CompileAssemblyFromSource(cp, code);
			if (cr.Errors.Count > 0) {
				Console.WriteLine(code);
				throw new Exception(cr.Errors[0].ErrorText);
			}

			Assembly a = cr.CompiledAssembly;
			return a;
		}

	}
}
