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
		string _ResultKey = null;
		IProvider<IDictionary<string, object>, bool> _RunCondition = null;
		static ILog log = LogManager.GetLogger(typeof(ChainProviderCall));

		public IProvider<IDictionary<string, object>, bool> RunCondition {
			get { return _RunCondition; }
			set { _RunCondition = value; }
		}

		public string ResultKey {
			get { return _ResultKey; }
			set { _ResultKey = value; }
		}

		public ChainProviderCall() { }

		public ChainProviderCall(IProvider basePrv) : base(basePrv) {

		}

		public void Execute(IDictionary<string, object> context) {
			if (RunCondition!=null)
				if (!RunCondition.Provide(context)) {
					log.Debug("[condition=false] [context={0}]", context); 
					return;
				} else {
					log.Debug("[condition=true] [context={0}]", context); 
				}

			object res = Provide(context);
			if (ResultKey!=null) {
				log.Debug("[resultKey={0}] [result={1}]", ResultKey, res); 
				context[ResultKey] = res;
			}
		}

	}

}
