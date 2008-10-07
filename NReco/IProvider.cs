using System;
using System.Collections.Generic;
using System.Text;

namespace NReco {
	
	/// <summary>
	/// Generic provider interface definition
	/// </summary>
	/// <typeparam name="Context">context type</typeparam>
	/// <typeparam name="Result">result type</typeparam>
	public interface IProvider<ContextT,ResultT> {
		ResultT Provide(ContextT context);
	}

	/// <summary>
	/// Abstract provider interface definition
	/// </summary>
	public interface IProvider {
		object Provide(object context);
	}

}
