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
using System.Text;

using NReco.Providers;
using NReco.Logging;

namespace NReco.Operations {

	/// <summary>
	/// Chain-oriented provider wrapper  
	/// </summary>
	public class ChainProviderCall : ProviderCall, IOperation<IDictionary<string, object>> {
		static ILog log = LogManager.GetLogger(typeof(ChainProviderCall));

		/// <summary>
		/// Get or set call condition (optional).
		/// </summary>
		public IProvider<IDictionary<string, object>, bool> RunCondition { get; set; }

		/// <summary>
		/// Get or set context key where provider's result will be stored.
		/// </summary>
		public string ResultKey { get; set; }

		public ChainProviderCall() {
			ResultKey = null;
		}

		public ChainProviderCall(IProvider<object,object> basePrv) : base(basePrv) {

		}

		public void Execute(IDictionary<string, object> context) {
			if (RunCondition!=null)
				if (!RunCondition.Provide(context)) {
					if (log.IsEnabledFor(LogEvent.Debug))
						log.Write(LogEvent.Debug, new{Condition=false,Context=context});
					return;
				} else {
					if (log.IsEnabledFor(LogEvent.Debug))
						log.Write(LogEvent.Debug, new{Condition=true,Context=context});
				}

			object res = Provide(context);
			if (ResultKey!=null) {
				if (log.IsEnabledFor(LogEvent.Debug))
					log.Write(LogEvent.Debug,new{Result=res,ResultKey=ResultKey});
				context[ResultKey] = res;
			}
		}

	}

}
