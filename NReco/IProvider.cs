using System;
using System.Collections.Generic;
using System.Text;

namespace NReco {
	
	/// <summary>
	/// Generic provider interface definition
	/// </summary>
	/// <typeparam name="Context">context type</typeparam>
	/// <typeparam name="Result">result type</typeparam>
	public interface IProvider<Context,Result> : IProvider {
		Result Get(Context context);
	}

	/// <summary>
	/// Abstract provider interface definition
	/// </summary>
	public interface IProvider {
		object Get(object context);
	}

}
