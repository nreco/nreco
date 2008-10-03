using System;
using System.Collections.Generic;
using System.Text;
using System.Reflection;

namespace NReco.Operations {
	
	public class EvalCode : IProvider {
		string _ClassName;
		string _MethodName;
		string _Code;
		IProvider<string,Assembly> _CodeAssemblyProvider;

		public IProvider<string,Assembly> CodeAssemblyProvider {
			get { return _CodeAssemblyProvider; }
			set { _CodeAssemblyProvider = value; }
		}

		public string Code {
			get { return _Code; }
			set { _Code = value; }
		}

		public string ClassName {
			get { return _ClassName; }
			set { _ClassName = value; }
		}

		public string MethodName {
			get { return _MethodName; }
			set { _MethodName = value; }
		}

		public object Get(object context) {
			Assembly assembly = CodeAssemblyProvider.Get(Code);
			object o = assembly.CreateInstance(ClassName);
			Type t = o.GetType();
			MethodInfo mi = t.GetMethod("EvalCode");

			object s = mi.Invoke(o, null);
			
			return s;
		}

	}
}
