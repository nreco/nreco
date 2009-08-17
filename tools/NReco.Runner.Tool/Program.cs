#region License
/*
 * NReco library (http://code.google.com/p/nreco/)
 * Copyright 2008,2009 Vitaliy Fedorchenko
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
using System.Linq;
using System.Text;
using System.Threading;
using System.Configuration;

using NReco;
using NReco.Runner;
using NReco.Logging;
using NI.Winter;
using log4net;

namespace NReco.Runner.Tool {
	
	public class Program {
		public const string ServiceParam = "service";
		public const string ThreadCountParam = "threads";
		public const string ThreadIterationCountParam = "iterations";
		public const string ThreadIterationDelayParam = "iterationDelay";
		public const string ThreadTimeoutParam = "threadTimeout";
		public const string TimeoutParam = "timeout";
		public const string ContextParam = "context";

		static CmdParamDescriptor[] paramDescriptors = new CmdParamDescriptor[] {
			new CmdParamDescriptor { Name=ServiceParam, Aliases=new string[] {"s","service"}, ParamType=typeof(string), DefaultValue=null },
			new CmdParamDescriptor { Name=ThreadCountParam, Aliases=new string[] {"threads"}, ParamType=typeof(int), DefaultValue=(int)1 },
			new CmdParamDescriptor { Name=ThreadIterationCountParam, Aliases=new string[] {"i","iterations"}, ParamType=typeof(int), DefaultValue=(int)1 },
			new CmdParamDescriptor { Name=ThreadIterationDelayParam, Aliases=new string[] {"iterationdelay"}, ParamType=typeof(int), DefaultValue=(int)-1 },
			new CmdParamDescriptor { Name=ThreadTimeoutParam, Aliases=new string[] {"threadtimeout"}, ParamType=typeof(int), DefaultValue=(int)-1 },
			new CmdParamDescriptor { Name=TimeoutParam, Aliases=new string[] {"timeout"}, ParamType=typeof(int), DefaultValue=(int)-1 },
			new CmdParamDescriptor { Name=ContextParam, Aliases=new string[] {"c","context"}, ParamType=typeof(string), DefaultValue=null }
		};

		static void Main(string[] args) {
			// initialize core subsystems
			NReco.Logging.LogManager.Configure(new NReco.Log4Net.Logger());
			log4net.Config.XmlConfigurator.Configure();
			NReco.Converting.ConvertManager.Configure();
			var serviceConfig = (IComponentsConfig)ConfigurationSettings.GetConfig("components");
			var log = NReco.Logging.LogManager.GetLogger(typeof(Program));

			var runnerParams = ExtractCmdParams(args, paramDescriptors);
			var threadsCount = (int)runnerParams[ThreadCountParam];
			var iterationsCount = (int)runnerParams[ThreadIterationCountParam];
			var iterationDelay = (int)runnerParams[ThreadIterationDelayParam];
			var serviceName = (string)runnerParams[ServiceParam];
			var serviceContextParam = (string)runnerParams[ContextParam];
			var threadTimeoutSec = (int)runnerParams[ThreadTimeoutParam];
			var totalTimeoutSec = (int)runnerParams[TimeoutParam];
			// simple validation
			if (String.IsNullOrEmpty(serviceName)) {
				log.Write(LogEvent.Fatal, "Service name is required parameter (-s [servicename])");
				return;
			}
			// log params
			log.Write(LogEvent.Info, "Parameters: service={0}, threads={1}, iterations={2}", serviceName, threadsCount, iterationsCount);


			RunnerThread[] threads = new RunnerThread[threadsCount];
			// create thead instances
			for (int threadIdx = 0; threadIdx < threadsCount; threadIdx++) {
				threads[threadIdx] = new RunnerThread(
					serviceConfig, serviceName, 
					new RunnerContext(threadIdx, serviceContextParam), 
					iterationsCount, iterationDelay);
			}
			// start them!
			var startTime = DateTime.Now;
			foreach (var t in threads)
				t.Start();

			// wait/check timeout loop
			while (true) {
				// check threads
				bool allFinished = true;
				foreach (var t in threads) {
					t.CheckTimeout( threadTimeoutSec );
					if (t.IsAlive)
						allFinished = false;
				}
				if (allFinished) {
					log.Write(LogEvent.Info, "All threads are finished");
					return;
				}
				// check total timeout
				if (totalTimeoutSec>=0 && startTime.AddSeconds(totalTimeoutSec)<DateTime.Now ) {
					log.Write(LogEvent.Warn, "Runner timeout reached, stopping (duration={0})", 
						DateTime.Now.Subtract(startTime) );
					// aborting alive threads
					foreach (var t in threads)
						t.Abort();
					return;
				}
				// wait sleep
				Thread.Sleep(100);
			}
		}

		public static IDictionary<string, object> ExtractCmdParams(string[] args, CmdParamDescriptor[] paramDescriptors) {
			IDictionary<string, object> cmdParams = new Dictionary<string, object>();
			for (int i = 0; i < args.Length; i++) {
				if (args[i].StartsWith("-")) {
					string pName = args[i].Substring(1);
					string pValue = null;
					if ((i + 1) < args.Length && !args[i + 1].StartsWith("-")) {
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
						throw new Exception(String.Format("Unknown parameter '{0}'", pName));
				}
			}
			foreach (var pDescr in paramDescriptors)
				if (!cmdParams.ContainsKey(pDescr.Name))
					cmdParams[pDescr.Name] = pDescr.DefaultValue;
			return cmdParams;
		}

		public class CmdParamDescriptor {
			public string Name { get; set; }
			public string[] Aliases { get; set; }
			public Type ParamType { get; set; }
			public object DefaultValue { get; set; }

			public bool IsMatch(string paramName) {
				for (int i = 0; i < Aliases.Length; i++)
					if (Aliases[i] == paramName)
						return true;
				return false;
			}

		}


	}

}
