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
