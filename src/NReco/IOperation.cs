using System;
using System.Collections.Generic;
using System.Text;

namespace NReco {
	
	/// <summary>
	/// Generic operation interface definition
	/// </summary>
	/// <typeparam name="Context">context type</typeparam>
	public interface IOperation<ContextT> {
		void Execute(ContextT context);
	}

	/// <summary>
	/// Abstract operation interface definition
	/// </summary>
	public interface IOperation {
		void Execute(object context);
	}

}
