using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace NReco.Transform.Tool {
	
	public class ConsoleTraceListener : System.Diagnostics.ConsoleTraceListener {
		static Regex regex = new Regex("[:] [0-9]+ [:]", RegexOptions.Singleline);

		public ConsoleTraceListener() {
		}

		public override void Write(string message) {
			if (message.IndexOf(": 0 :") >= 0)
				return;
			base.Write(message);
		}
		public override void WriteLine(string message) {
			message = message.Replace("NReco.Transform.", "").Replace("\t", " ");
			base.WriteLine(message);
		}
	}

}
