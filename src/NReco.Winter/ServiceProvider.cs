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

using NI.Winter;
using NReco.Converters;

namespace NReco.Winter {
	
	public class ServiceProvider : NI.Winter.ServiceProvider {

		public ServiceProvider() : base() {
			CreateValueFactory();
		}

		public ServiceProvider(IComponentsConfig config) : base() {
			CreateValueFactory();
			Config = config;
		}

		public ServiceProvider(IComponentsConfig config, bool countersEnabled) : base() {
			CreateValueFactory();
			CountersEnabled = countersEnabled;
			Config = config;
		}

		protected void CreateValueFactory() {
			ValueFactory = new NReco.Winter.LocalValueFactory(this);
		}

	}
}
