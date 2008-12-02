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

namespace NReco.Transform.Tool {
	
	public class CmdParamDescriptor {
		string _Name;
		string[] _Aliases;
		Type _ParamType;

		public string Name {
			get { return _Name; }
		}

		public string[] Aliases {
			get { return _Aliases; }
		}

		public Type ParamType {
			get { return _ParamType; }
		}

		public CmdParamDescriptor(string name, string[] aliases, Type pType) {
			_Name = name;
			_Aliases = aliases;
			_ParamType = pType;
		}

		public bool IsMatch(string paramName) {
			for (int i = 0; i < _Aliases.Length; i++)
				if (_Aliases[i] == paramName)
					return true;
			return false;
		}

	}

}
