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

using NI.Ioc;
using NReco.Logging;
using NReco.Converting;

namespace NReco.Application.Console {
	
	public class RunnerThread {
		static ILog log = LogManager.GetLogger(typeof(RunnerThread));

        public static IDictionary<Thread, RunnerThread> RunnerThreadsMap = new Dictionary<Thread, RunnerThread>();

        public IComponentFactory ComponentFactory { get; private set; }

		Thread Thrd;
		IComponentFactoryConfiguration Cfg;
		string ServiceName;
		ActionContext Context;
		DateTime? StartTime;
		int IterationsCount;
		int Iteration = 0;
		int IterationDelay;

		public RunnerThread(IComponentFactoryConfiguration cfg, string service, ActionContext context, int iterations, int iterationDelay) {
			Cfg = cfg;
			ServiceName = service;
			Context = context;
			IterationsCount = iterations;
			IterationDelay = iterationDelay;
			ComponentFactory = new NReco.Application.Ioc.ComponentFactory(Cfg);
			Thrd = new Thread(new ThreadStart(Execute));

            RunnerThreadsMap.Add(Thrd, this);
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
            var service = ComponentFactory.GetComponent(ServiceName);
			if (service == null) {
				log.Write(LogEvent.Error, "Service does not exist (thread={0}, service={1})", Context.ThreadIndex, ServiceName, ServiceName);
			} else {
				// is it convertible to Action delegate
				if (!(TryExecuteWithActionContext(service, Context) ||
						TryExecuteWithObjectContext(service, Context) ||
						TryExecuteWithoutContext(service, Context))) {
							log.Write(LogEvent.Info, "service={0} is not an action (type={1})", ServiceName, service.GetType() );
				}

			}
			log.Write(LogEvent.Info, "Finished (thread={0}, service={1}, iteration={2}/{3}, duration={4})",
				Context.ThreadIndex, ServiceName, Iteration + 1, IterationsCount, DateTime.Now.Subtract(StartTime.Value));
		}

		protected bool TryExecuteWithActionContext(object service, ActionContext context) {
			var opConv = ConvertManager.FindConverter(service.GetType(), typeof(Action<ActionContext>));
			if (opConv != null) {
				var opInstance = (Action<ActionContext>)opConv.Convert(service, typeof(Action<ActionContext>));
				log.Write(LogEvent.Info, "Executing action (thread={0}, service={1})", Context.ThreadIndex, ServiceName);
				opInstance(Context);
				return true;
			} else {
				return false;
			}
		}

		protected bool TryExecuteWithObjectContext(object service, ActionContext context) {
			var opConv = ConvertManager.FindConverter(service.GetType(), typeof(Action<object>));
			if (opConv != null) {
				var opInstance = (Action<object>)opConv.Convert(service, typeof(Action<object>));
				log.Write(LogEvent.Info, "Executing action (thread={0}, service={1})", Context.ThreadIndex, ServiceName);
				opInstance(Context.Parameter);
				return true;
			} else {
				return false;
			}
		}

		protected bool TryExecuteWithoutContext(object service, ActionContext context) {
			var opConv = ConvertManager.FindConverter(service.GetType(), typeof(Action));
			if (opConv != null) {
				var opInstance = (Action)opConv.Convert(service, typeof(Action));
				log.Write(LogEvent.Info, "Executing action (thread={0}, service={1})", Context.ThreadIndex, ServiceName);
				opInstance();
				return true;
			} else {
				return false;
			}
		}


	}

    public static class ThreadExtensions {
        public static RunnerThread GetRunnerThread(this Thread thread) {
            return RunnerThread.RunnerThreadsMap[thread];
        }
    }
}
