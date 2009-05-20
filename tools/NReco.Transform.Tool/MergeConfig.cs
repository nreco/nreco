using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace NReco.Transform.Tool {
	
	public class MergeConfig {

		public string[] Sources { get; set; }
		bool IgnoreCase = true;

		public MergeConfig(string fileName, string defaultRootPath) {
			var sourcesList = new List<string>();
			using (var rdr = new StreamReader(fileName)) {
				string line;
				while ((line = rdr.ReadLine()) != null) {
					if (!Path.IsPathRooted(line))
						line = Path.Combine(defaultRootPath, line);
					sourcesList.Add( NormalizePath(line, true) );
				}
			}
			Sources = sourcesList.ToArray();
		}

		protected string NormalizePath(string path, bool isDir) {
			path = Path.GetFullPath(path);
			if (IgnoreCase)
				path = path.ToLower();
			path = path.Replace(Path.AltDirectorySeparatorChar, Path.DirectorySeparatorChar);
			if (isDir && !path.EndsWith(Path.DirectorySeparatorChar.ToString()))
				path += Path.DirectorySeparatorChar;
			return path;
		}

		public int MatchSource(string fileName) {
			var fileNameCmp = NormalizePath(fileName, false);
			for (int i = 0; i < Sources.Length; i++)
				if (fileNameCmp.StartsWith(Sources[i]))
					return i;
			return -1;
		}

	}

}
