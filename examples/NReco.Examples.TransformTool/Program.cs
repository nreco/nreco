using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace NReco.Examples.TransformTool {
	class Program {
		static void Main(string[] args) {

			using (StreamReader rdr = new StreamReader("sitemap.xml")) {
				Console.WriteLine("sitemap.xml:\n----------------");
				Console.WriteLine(rdr.ReadToEnd());
			}

			using (StreamReader rdr = new StreamReader("script.js")) {
				Console.WriteLine("script.js:\n----------------");
				Console.WriteLine(rdr.ReadToEnd());
			}

			Console.ReadKey();
		}
	}
}
