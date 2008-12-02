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
using System.Configuration;
using System.Text;

using NReco.Logging;
using NReco.Winter;
using NI.Winter;
using NI.Common;

namespace NReco.Transform.Tool {
	
	public class Program {
		const string BasePathParam = "BasePath";
		const string IsIncrementalParam = "IsIncremental";
		static CmdParamDescriptor[] paramDescriptors = new CmdParamDescriptor[] {
			new CmdParamDescriptor(BasePathParam, new string[] {"base","b"}, typeof(string) ),
			new CmdParamDescriptor(IsIncrementalParam, new string[] {"incremental","i"}, typeof(bool) )
		};

		static ILog log = LogManager.GetLogger(typeof(Program));

		static int Main(string[] args) {
			LogManager.Configure(new TraceLogger(false,false));
			IDictionary<string, object> cmdParams;
			try {
				cmdParams = ExtractCmdParams(args, paramDescriptors);
			} catch (Exception ex) {
				log.Write(LogEvent.Fatal, ex.Message, ex);
				Console.Error.WriteLine(ex.Message);
				return 1;
			}
			if (!cmdParams.ContainsKey(BasePathParam)) {
				cmdParams[BasePathParam] = Environment.CurrentDirectory;
				log.Write(LogEvent.Info, "Base path is not defined, using current directory: {0}", cmdParams[BasePathParam]);
			}
			if (!cmdParams.ContainsKey(IsIncrementalParam)) {
				cmdParams[IsIncrementalParam] = false;
				log.Write(LogEvent.Info, "Incremental processing is not defined, by default: {0}.", cmdParams[IsIncrementalParam]);
			}

			IComponentsConfig config = ConfigurationSettings.GetConfig("components") as IComponentsConfig;
			INamedServiceProvider srvPrv = new NReco.Winter.ServiceProvider(config);

			IOperation<string> folderRuleProcessor = srvPrv.GetService("folderRuleProcessor") as IOperation<string>;
			if (folderRuleProcessor==null) {
				Console.Error.WriteLine("Configuration error: missed or incorrect 'folderRuleProcessor' component");
				return 2;
			}

			string rootFolder = (string)cmdParams[BasePathParam];

			log.Write(LogEvent.Info, "Reading Folder: {0}", rootFolder);
			DateTime dt = DateTime.Now;
			folderRuleProcessor.Execute(rootFolder);

			log.Write(LogEvent.Info, "Apply time: {0}", DateTime.Now.Subtract(dt).TotalSeconds.ToString());

            return 0;
		}

		static IDictionary<string, object> ExtractCmdParams(string[] args, CmdParamDescriptor[] paramDescriptors) {
			IDictionary<string, object> cmdParams = new Dictionary<string, object>();
			for (int i=0; i<args.Length; i++) {
				if (args[i].StartsWith("-")) {
					string pName = args[i].Substring(1);
					string pValue = null;
					if ((i + 1) < args.Length && !args[i+1].StartsWith("-") ) {
						pValue = args[i++ + 1].Trim();
					}
					bool found = false;
					foreach (CmdParamDescriptor pDescr in paramDescriptors)
						if (pDescr.IsMatch(pName)) {
							try {
								cmdParams[pDescr.Name] = Convert.ChangeType(pValue, pDescr.ParamType);
							} catch (Exception ex) {
								throw new Exception(
									String.Format("Invalid parameter '{0}': expected {1} ({2})",
										pDescr.Name, pDescr.ParamType.Name, ex.Message));
							}
							found = true;
							break;
						}
					if (!found)
						throw new Exception( String.Format("Unknown parameter '{0}'", pName) );
				}
            }
            return cmdParams;
		}



	}

}
