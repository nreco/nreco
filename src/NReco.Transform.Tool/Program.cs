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

using NReco.Winter;
using NI.Winter;
using NI.Common;

namespace NReco.Transform.Tool {
	
	public class Program {
		static void Main(string[] args) {
			IComponentsConfig config = ConfigurationSettings.GetConfig("components") as IComponentsConfig;
			INamedServiceProvider srvPrv = new NReco.Winter.ServiceProvider(config);

			IOperation<string> folderRuleProcessor = srvPrv.GetService("folderRuleProcessor") as IOperation<string>;
			if (folderRuleProcessor==null) {
				Console.WriteLine("Configuration error: missed or incorrect 'folderRuleProcessor' component");
				return;
			}
			if (args.Length<1) {
				Console.WriteLine("Root folder is not defined - current is used by default");
			}
			string rootFolder = args.Length<1 ? Environment.CurrentDirectory : args[0];

			Console.WriteLine("Reading Folder: "+rootFolder);
			DateTime dt = DateTime.Now;
			folderRuleProcessor.Execute(rootFolder);
			Console.WriteLine("Apply time: "+DateTime.Now.Subtract(dt).TotalSeconds.ToString() );
		}
	}

}
