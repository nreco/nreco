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

using NI.Winter;
using NReco.Logging;
using NReco.Converting;

namespace NReco.Runner.Tool {
	
	public class RunnerThread {
		static ILog log = LogManager.GetLogger(typeof(RunnerThread));

		Thread Thrd;
		IComponentsConfig Cfg;
		ServiceProvider SrvPrv;
		string ServiceName;
		RunnerContext Context;
		DateTime? StartTime;
		int IterationsCount;
		int Iteration = 0;
		int IterationDelay;

		public RunnerThread(IComponentsConfig cfg, string service, RunnerContext context, int iterations, int iterationDelay) {
			Cfg = cfg;
			ServiceName = service;
			Context = context;
			IterationsCount = iterations;
			IterationDelay = iterationDelay;
			SrvPrv = new NReco.Winter.ServiceProvider(Cfg);
			Thrd = new Thread(new ThreadStart(Execute));
			
		}

		public void Start() {
			StartTime = DateTime.Now;
			Thrd.Start();
		}

		public bool IsAlive {
			get { return Thrd.IsAlive; }
		}

		public void CheckTimeout(int timeoutSeconds) {

			if (!StartTime.HasValue || timeoutSeconds < 0 || StartTime.Value.AddSeconds(timeoutSeconds)>DateTime.Now ) return;
			// abort
			log.Write(LogEvent.Warn, "Thread timeout reached (thread duration={2}), aborting (thread={0}, service={1})", 
					Context.ThreadIndex, ServiceName, DateTime.Now.Subtract(StartTime.Value) );
			Abort();
		}

		public void Abort() {
			StartTime = null;
			try {
				if (Thrd.ThreadState != ThreadState.Aborted && Thrd.ThreadState != ThreadState.Stopped)
					Thrd.Abort();
			} catch (Exception ex) {
				log.Write(LogEvent.Warn, "Thread abort exception: {0}", ex);
			}
		}

		protected void Execute() {
			for (; Iteration < IterationsCount; Iteration++) {
				// no delay for first iteration
				if (Iteration > 0 && IterationDelay >= 0)
					Thread.Sleep(TimeSpan.FromSeconds(IterationDelay));
				ExecuteService();
			}
		}

		protected void ExecuteService() {
			log.Write(LogEvent.Info, "Started (thread={0}, service={1}, iteration={2}/{3})", Context.ThreadIndex, ServiceName, Iteration+1, IterationsCount);
			var service = SrvPrv.GetObject(ServiceName);
			if (service == null) {
				log.Write(LogEvent.Error, "Service does not exist (thread={0}, service={1})", Context.ThreadIndex, ServiceName, ServiceName);
			} else {
				// try get IOperation instance
				var opConv = ConvertManager.FindConverter(service.GetType(), typeof(IOperation<RunnerContext>));
				if (opConv != null) {
					var opInstance = (IOperation<RunnerContext>)opConv.Convert(service, typeof(IOperation<RunnerContext>));
					log.Write(LogEvent.Info, "Executing operation (thread={0}, service={1})", Context.ThreadIndex, ServiceName);
					opInstance.Execute(Context);
				} else {
					// try get IProvider instance
					var prvConv = ConvertManager.FindConverter(service.GetType(), typeof(IProvider<RunnerContext, object>));
					if (prvConv != null) {
						var prvInstance = (IProvider<RunnerContext, object>)opConv.Convert(service, typeof(IProvider<RunnerContext, object>));
						log.Write(LogEvent.Info, "Executing provider (thread={0}, service={1})", Context.ThreadIndex, ServiceName);
						var res = prvInstance.Provide(Context);
						log.Write(LogEvent.Info, "Provider result: {2} (thread={0}, service={1})", Context.ThreadIndex, ServiceName, res ?? "NULL");
					} else {
						// don't know how to execute
						log.Write(LogEvent.Warn, "Unkown service type: nothing to call (thread={0}, service={1})", Context.ThreadIndex, ServiceName);
					}
				}
			}
			log.Write(LogEvent.Info, "Finished (thread={0}, service={1}, iteration={2}/{3}, duration={4})",
				Context.ThreadIndex, ServiceName, Iteration + 1, IterationsCount, DateTime.Now.Subtract(StartTime.Value));
		}


	}

}
