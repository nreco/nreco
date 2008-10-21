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
using System.Reflection.Emit;
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
		
		protected string LocateByLoadedAssemblies(string assemblyRef, string[] loadedLocations) {
			for (int i = 0; i < loadedLocations.Length; i++)
				if (loadedLocations[i].ToLower().EndsWith(assemblyRef.ToLower()))
					return loadedLocations[i];
			return assemblyRef;
		}
		
		protected string[] GetLoadedAssembliesLocations(Assembly[] loadedAssemblies) {
			List<string> res = new List<string>();
			for (int i=0; i<loadedAssemblies.Length; i++)
				if ( !(loadedAssemblies[i] is AssemblyBuilder) && !String.IsNullOrEmpty(loadedAssemblies[i].Location))
					res.Add( loadedAssemblies[i].Location );
			return res.ToArray();
		}

		public Assembly Provide(string code) {
			CompilerParameters cp = new CompilerParameters();
			Assembly[] knownLoadedAssemblies = AppDomain.CurrentDomain.GetAssemblies();
			string[] knownLocations = GetLoadedAssembliesLocations(knownLoadedAssemblies);
			if (RefAssemblies!=null) 
				for (int i = 0; i < RefAssemblies.Length; i++) {
					string assemblyRef = RefAssemblies[i];
					if (!assemblyRef.ToLower().StartsWith("system."))
						assemblyRef = LocateByLoadedAssemblies(assemblyRef, knownLocations);
					cp.ReferencedAssemblies.Add(assemblyRef);
				}
			cp.CompilerOptions = "/t:library";
			cp.GenerateInMemory = true;
			cp.IncludeDebugInformation = false;
			StringBuilder sb = new StringBuilder();
			CompilerResults cr = DomProvider.CompileAssemblyFromSource(cp, code);
			if (cr.Errors.Count > 0) {
				Console.WriteLine(code);
				throw new Exception(cr.Errors[0].ErrorText);
			}

			Assembly a = cr.CompiledAssembly;
			return a;
		}

	}
}
