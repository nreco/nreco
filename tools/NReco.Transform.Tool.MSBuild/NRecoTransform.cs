using System;
using System.Collections.Generic;
using System.Reflection;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.IO;
using System.Resources;
using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;


namespace NReco.Transform.Tool.MSBuild {
	
	public class NRecoTransform : Task {

		public bool Incremental { get; set; }
		public string BasePath { get; set; }
		public string TransformToolPath { get; set; }

		public NRecoTransform() {
			Incremental = true;
			TransformToolPath = Path.Combine( Path.GetDirectoryName(typeof(NRecoTransform).Assembly.Location), "NReco.Transform.Tool.exe" );
		}

		public override bool Execute() {
			try {
				Process proc = new Process();
				proc.StartInfo.RedirectStandardOutput = true;
				proc.StartInfo.FileName = TransformToolPath;
				proc.StartInfo.Arguments = String.Format("-i {0} -b {1}", Incremental.ToString().ToLower(), BasePath);
				proc.StartInfo.UseShellExecute = false;
				proc.StartInfo.CreateNoWindow = true;
				proc.StartInfo.ErrorDialog = false;
				proc.StartInfo.WorkingDirectory = BasePath;
				proc.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
				Log.LogMessage(proc.StartInfo.FileName + " " + proc.StartInfo.Arguments);

				try {
					proc.Start();
					var procOutput = proc.StandardOutput.ReadToEnd();
					proc.WaitForExit();
					if (proc.ExitCode != 0) {
						// error detected. lets read output
						var err = procOutput.Length > 4000 ? procOutput.Substring(0, 4000) : procOutput;
						Log.LogError("Transformation failed: {0}", err);
					}
					else {
						Log.LogMessage(procOutput);
						return false;
					}
				} catch (Exception ex) {
					Log.LogErrorFromException(ex);
					return false;
				} finally {
					proc.Dispose();
				}

			}
			catch (Exception ex) {
				Log.LogError("General error: {0}", ex.Message);
				return false;
			}
			return true;
		}

	}
}
