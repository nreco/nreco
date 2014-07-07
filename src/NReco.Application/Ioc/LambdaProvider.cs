using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using NReco.Linq;
using NI.Ioc;

namespace NReco.Application.Ioc {
	
	/// <summary>
	/// Object provider based on lambda parser. Used by NReco infrastructure.
	/// </summary>
	public class LambdaProvider : IComponentFactoryAware, ILambdaProvider {

		public IComponentFactory ComponentFactory {	get;set; }

		public string Expression { get; private set; }

		public LambdaProvider(string expression) {
			Expression = expression;
		}

		public object GetValue(object context) {
			var lambdaParser = new LambdaParser();
			var lambdaContext = new Dictionary<string,object>();
			lambdaContext["ComponentFactory"] = ComponentFactory;
			lambdaContext["Context"] = context;
			return lambdaParser.Eval(Expression,lambdaContext);
		}

	}

	public interface ILambdaProvider {
		object GetValue(object context);
	}

}
